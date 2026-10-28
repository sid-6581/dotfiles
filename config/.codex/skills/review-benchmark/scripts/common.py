"""Shared on-disk formats and validation; no third-party dependencies."""

import contextlib
import hashlib
import json
import os
from pathlib import Path
import socket
import subprocess
import tempfile

SKILL = Path(__file__).resolve().parent.parent
VERDICTS = ("confirmed_defect", "supported_concern", "refuted", "unresolved")
SEVERITIES = ("low", "medium", "high", "critical")


def read_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def write_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".writing-")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as output:
            json.dump(value, output, ensure_ascii=False, indent=2)
            output.write("\n")
            output.flush()
            os.fsync(output.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def git(repo, *args):
    return subprocess.check_output(
        ["git", "-c", "core.fsmonitor=false", "-C", str(repo), *args],
        stderr=subprocess.PIPE,
    )


def inside(root, relative):
    relative = Path(relative)
    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError(f"Expected a relative path within the snapshot: {relative}")
    path = root / relative
    if not path.resolve().is_relative_to(root.resolve()):
        raise ValueError(f"Path escapes snapshot: {relative}")
    return path


@contextlib.contextmanager
def locked(root):
    """A crash leaves a lock for explicit recovery; never guess that a live run is stale."""
    path = root / ".lock"
    try:
        fd = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except FileExistsError as error:
        raise ValueError(
            f"Experiment locked: {path}. Use unlock only after the owner has stopped.",
        ) from error
    try:
        with os.fdopen(fd, "w") as output:
            json.dump({"pid": os.getpid(), "host": socket.gethostname()}, output)
        yield
    finally:
        path.unlink()


def unlock(root):
    record = read_json(root / ".lock")
    if record["host"] != socket.gethostname():
        raise ValueError("Lock belongs to another host; recover it on that host.")
    try:
        os.kill(record["pid"], 0)
    except ProcessLookupError:
        (root / ".lock").unlink()
    else:
        raise ValueError("The lock owner is still running; do not resume concurrently.")


def validate_review(value):
    if not isinstance(value, dict) or not isinstance(value.get("summary"), str):
        raise ValueError("Review must be an object with a summary string")
    findings = value.get("findings")
    if not isinstance(findings, list):
        raise ValueError("Review findings must be a list")
    ids = set()
    for finding in findings:
        if not isinstance(finding, dict):
            raise ValueError("Each finding must be an object")
        for field in (
            "id",
            "title",
            "file",
            "evidence",
            "scenario",
            "impact",
            "recommendation",
            "verification",
        ):
            if not isinstance(finding.get(field), str) or not finding[field].strip():
                raise ValueError(f"Finding requires a nonempty {field}")
        if finding["id"] in ids:
            raise ValueError("Duplicate finding ID")
        ids.add(finding["id"])
        if finding.get("kind") not in ("defect", "design_concern"):
            raise ValueError("Unknown finding kind")
        if finding.get("category") not in (
            "correctness",
            "robustness",
            "performance",
            "security",
            "maintainability",
            "readability",
        ):
            raise ValueError("Unknown finding category")
        if finding.get("severity") not in SEVERITIES:
            raise ValueError("Unknown severity")
        if finding.get("confidence") not in ("low", "medium", "high"):
            raise ValueError("Unknown confidence")
        for field in ("line_start", "line_end"):
            if type(finding.get(field)) is not int or finding[field] < 1:
                raise ValueError(f"Invalid {field}")
        if finding["line_end"] < finding["line_start"]:
            raise ValueError("Reversed line range")
    for field in ("coverage", "checks_performed", "limitations"):
        if not isinstance(value.get(field), list):
            raise ValueError(f"Review requires a {field} list")
    return value


def latest_runs(root):
    records = []
    for cell in read_json(root / "experiment.json")["schedule"]:
        attempts = sorted(
            (root / "runs" / cell["run_id"]).glob("attempt-*/record.json"),
        )
        records.append(
            read_json(attempts[-1]) if attempts else {**cell, "status": "pending"},
        )
    return records
