"""Freeze tracked Git content without changing the reviewed checkout."""

import datetime
import fnmatch
import os
from pathlib import Path
import random
import subprocess
import uuid

from common import SKILL, digest, git, inside, read_json, write_json


def manifest(root):
    entries = {}
    for path in sorted(root.rglob("*")):
        relative = path.relative_to(root).as_posix()
        if path.is_symlink():
            target = os.readlink(path)
            if Path(target).is_absolute() or not path.resolve().is_relative_to(
                root.resolve(),
            ):
                raise ValueError(f"Symlink escapes snapshot: {relative} -> {target}")
            entries[relative] = {"link": target}
        elif path.is_file():
            entries[relative] = {
                "sha256": digest(path.read_bytes()),
                "executable": bool(path.stat().st_mode & 0o111),
            }
    return entries


def verify(root):
    experiment = read_json(root / "experiment.json")
    if manifest(root / "snapshot") != read_json(root / "manifest.json"):
        raise ValueError("Frozen source changed; do not continue this experiment")
    if digest((root / "prompt.txt").read_bytes()) != experiment["prompt_sha256"]:
        raise ValueError("Frozen prompt changed; create a new experiment")


def excluded(name, patterns):
    return any(fnmatch.fnmatchcase(name, pattern) for pattern in patterns)


def archive(repo, revision, destination, patterns):
    """Read Git blobs directly; export-ignore and checkout filters must not alter review input."""
    destination.mkdir(parents=True)
    links = []
    entries = git(repo, "ls-tree", "-r", "-z", "--full-tree", revision).split(b"\0")
    with subprocess.Popen(
        ["git", "-C", str(repo), "cat-file", "--batch"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
    ) as batch:
        for entry in entries:
            if not entry:
                continue
            metadata, raw_name = entry.split(b"\t", 1)
            mode, kind, object_id = metadata.split()
            name = os.fsdecode(raw_name)
            if excluded(name, patterns):
                continue
            if kind != b"blob":
                raise ValueError(
                    f"Submodule requires a separate benchmark or an explicit exclude: {name}",
                )
            path = inside(destination, name)
            batch.stdin.write(object_id + b"\n")
            batch.stdin.flush()
            header = batch.stdout.readline().split()
            if len(header) != 3 or header[1] != b"blob":
                raise ValueError(f"Cannot read Git blob {object_id!r}")
            content = batch.stdout.read(int(header[2]))
            if batch.stdout.read(1) != b"\n":
                raise ValueError("Invalid Git batch response")
            if mode == b"120000":
                links.append((path, os.fsdecode(content)))
            else:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(content)
                path.chmod(0o755 if mode == b"100755" else 0o644)
        batch.stdin.close()
        if batch.wait() != 0:
            raise ValueError("Git blob reader failed")
    for path, target in links:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.symlink_to(target)
    manifest(destination)


def working_tree(repo, destination, patterns, include_untracked):
    destination.mkdir(parents=True)
    for entry in git(repo, "ls-files", "--stage", "-z").split(b"\0"):
        if entry.startswith(b"160000 "):
            name = os.fsdecode(entry.split(b"\t", 1)[1])
            if not excluded(name, patterns):
                raise ValueError(
                    f"Submodule requires a separate benchmark or an explicit exclude: {name}",
                )
    names = git(repo, "ls-files", "--cached", "-z").split(b"\0")
    if include_untracked:
        names += git(repo, "ls-files", "--others", "--exclude-standard", "-z").split(
            b"\0",
        )
    copied = {}
    links = []
    for raw in sorted(set(names) - {b""}):
        name = os.fsdecode(raw)
        if excluded(name, patterns):
            continue
        source = repo / name
        path = inside(destination, name)
        if source.is_symlink():
            target = os.readlink(source)
            links.append((path, target))
            copied[name] = {"link": target}
        elif source.is_file():
            if not source.resolve().is_relative_to(repo):
                raise ValueError(f"Tracked path escapes repository: {name}")
            path.parent.mkdir(parents=True, exist_ok=True)
            data = source.read_bytes()
            path.write_bytes(data)
            executable = bool(source.stat().st_mode & 0o111)
            path.chmod(0o755 if executable else 0o644)
            copied[name] = {"sha256": digest(data), "executable": executable}
    for path, target in links:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.symlink_to(target)
    for name, expected in copied.items():
        path = repo / name
        actual = (
            {"link": os.readlink(path)}
            if path.is_symlink()
            else {
                "sha256": digest(path.read_bytes()),
                "executable": bool(path.stat().st_mode & 0o111),
            }
        )
        if actual != expected:
            raise ValueError(f"Source changed while copying: {name}; prepare again")
    return manifest(destination)


def prepare(repo, config, output=None):
    if not isinstance(config, dict):
        raise ValueError("Configuration must be a JSON object")
    config = dict(config)
    repo = Path(
        os.fsdecode(git(repo, "rev-parse", "--show-toplevel")).strip(),
    ).resolve()
    allowed = {
        "scope",
        "base",
        "head",
        "reviewers",
        "repetitions",
        "concurrency",
        "timeout_seconds",
        "seed",
        "instructions",
        "exclude",
        "include_untracked",
    }
    if set(config) - allowed:
        raise ValueError(f"Unknown config keys: {sorted(set(config) - allowed)}")
    for key in ("base", "head", "instructions"):
        if key in config and not isinstance(config[key], str):
            raise ValueError(f"{key} must be a string")
    if type(config.get("include_untracked", False)) is not bool:
        raise ValueError("include_untracked must be a boolean")
    scope = config.get("scope", "diff")
    if scope not in ("diff", "worktree", "tree"):
        raise ValueError("scope must be diff, worktree or tree")
    if scope == "diff" and not config.get("base"):
        raise ValueError("A diff review requires an explicit base revision")
    if config.get("include_untracked") and scope != "worktree":
        raise ValueError("include_untracked applies only to worktree scope")
    for key, default in (
        ("repetitions", 1),
        ("concurrency", 1),
        ("timeout_seconds", 7200),
        ("seed", 1),
    ):
        config.setdefault(key, default)
        if type(config[key]) is not int or config[key] < (0 if key == "seed" else 1):
            raise ValueError(f"{key} must be a positive integer (seed may be zero)")
    reviewers = config.get("reviewers", [])
    if not isinstance(reviewers, list) or not reviewers:
        raise ValueError(
            "Choose at least one reviewer; no paid model matrix is implicit",
        )
    combinations = set()
    for reviewer in reviewers:
        if (
            not isinstance(reviewer, dict)
            or set(reviewer) != {"provider", "model", "effort"}
            or reviewer["provider"] not in ("codex", "claude")
        ):
            raise ValueError(
                "Each reviewer needs provider (codex/claude), model and effort",
            )
        if not all(
            isinstance(value, str) and value.strip() for value in reviewer.values()
        ):
            raise ValueError("Reviewer settings must be nonempty strings")
        if reviewer["effort"] not in (
            "minimal",
            "low",
            "medium",
            "high",
            "xhigh",
            "max",
        ):
            raise ValueError(
                "Unknown effort; settings are passed through without automatic mapping",
            )
        key = tuple(reviewer[k] for k in ("provider", "model", "effort"))
        if key in combinations:
            raise ValueError("Duplicate reviewer; use repetitions instead")
        combinations.add(key)
    head = (
        git(
            repo,
            "rev-parse",
            "--verify",
            "--end-of-options",
            f"{config.get('head', 'HEAD')}^{{commit}}",
        )
        .decode()
        .strip()
    )
    if scope == "worktree" and config.get("head", "HEAD") != "HEAD":
        raise ValueError("worktree scope compares the current checkout with HEAD")
    base = (
        git(
            repo,
            "rev-parse",
            "--verify",
            "--end-of-options",
            f"{config['base']}^{{commit}}",
        )
        .decode()
        .strip()
        if scope == "diff"
        else head
    )
    submodules = [
        line
        for line in git(repo, "ls-tree", "-r", head).decode().splitlines()
        if line.startswith("160000 ")
    ]
    patterns = config.get("exclude", [])
    if not isinstance(patterns, list) or not all(isinstance(p, str) for p in patterns):
        raise ValueError("exclude must be an array of path glob strings")
    unresolved = [
        line for line in submodules if not excluded(line.split("\t", 1)[1], patterns)
    ]
    if unresolved:
        raise ValueError(
            "Submodule contents need a separate benchmark or explicit exclude patterns: "
            + "; ".join(unresolved),
        )
    now = datetime.datetime.now(datetime.UTC)
    experiment_id = now.strftime("%Y%m%dT%H%M%SZ") + "-" + uuid.uuid4().hex[:8]
    data_home = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
    root = (
        Path(output).expanduser().resolve()
        if output
        else (data_home / "review-benchmark/runs" / experiment_id).resolve()
    )
    if root.is_relative_to(repo):
        raise ValueError("Output must be outside the repository being reviewed")
    root.mkdir(parents=True, exist_ok=False)
    snapshot = root / "snapshot"
    snapshot.mkdir()
    dirty_before = git(repo, "status", "--porcelain=v1", "--untracked-files=normal")
    diff = (
        git(repo, "diff", "--binary", "--no-ext-diff", "--no-textconv", base, head)
        if scope == "diff"
        else b""
    )
    if scope == "worktree":
        diff = git(repo, "diff", "--binary", "--no-ext-diff", "--no-textconv", "HEAD")
        working_tree(
            repo, snapshot / "source", patterns, config.get("include_untracked", False),
        )
        if diff != git(
            repo, "diff", "--binary", "--no-ext-diff", "--no-textconv", "HEAD",
        ) or dirty_before != git(
            repo, "status", "--porcelain=v1", "--untracked-files=normal",
        ):
            raise ValueError(
                "Checkout changed while freezing; prepare a new experiment",
            )
    else:
        archive(repo, head, snapshot / "source", patterns)
    if scope != "tree":
        archive(repo, base, snapshot / "baseline", patterns)
    entries = manifest(snapshot)
    changed = sorted(
        name.removeprefix("source/")
        for name, value in entries.items()
        if name.startswith("source/")
        and (
            scope == "tree"
            or entries.get(name.replace("source/", "baseline/", 1)) != value
        )
    )
    removed = sorted(
        name.removeprefix("baseline/")
        for name in entries
        if name.startswith("baseline/")
        and name.replace("baseline/", "source/", 1) not in entries
    )
    write_json(
        snapshot / "scope.json",
        {
            "scope": scope,
            "head": head,
            "base": base if scope != "tree" else None,
            "changed": changed,
            "removed": removed,
            "exclude": patterns,
            "untracked_included": bool(config.get("include_untracked")),
        },
    )
    if scope != "tree":
        patch = subprocess.run(
            [
                "git",
                "diff",
                "--no-index",
                "--binary",
                "--no-ext-diff",
                "--no-textconv",
                "baseline",
                "source",
            ],
            cwd=snapshot,
            capture_output=True,
        )
        if patch.returncode not in (0, 1):
            raise ValueError(patch.stderr.decode(errors="replace"))
        diff = patch.stdout
    (snapshot / "changes.patch").write_bytes(diff)
    instructions = config.get("instructions", "")
    if not isinstance(instructions, str):
        raise ValueError("instructions must be a string")
    prompt = (
        (SKILL / "assets/review.txt").read_text()
        + "\nExperiment-specific instructions:\n"
        + instructions
        + "\n"
    )
    (root / "prompt.txt").write_text(prompt, encoding="utf-8")
    schedule = []
    for reviewer in reviewers:
        for repetition in range(1, config["repetitions"] + 1):
            schedule.append(
                {
                    **reviewer,
                    "repetition": repetition,
                    "run_id": f"R{len(schedule) + 1:04}",
                },
            )
    random.Random(config["seed"]).shuffle(schedule)
    write_json(root / "manifest.json", manifest(snapshot))
    write_json(
        root / "experiment.json",
        {
            "schema_version": 1,
            "id": experiment_id,
            "created_at": now.isoformat(),
            "repository": str(repo),
            "config": config,
            "schedule": schedule,
            "prompt_sha256": digest(prompt.encode()),
            "source_head": head,
            "dirty_checkout_ignored": bool(dirty_before) and scope != "worktree",
        },
    )
    return root
