"""Durable attempts, process timing and explicit recovery."""

import concurrent.futures
import datetime
import os
from pathlib import Path
import shutil
import signal
import socket
import subprocess
import threading
import time

from common import digest, latest_runs, locked, read_json, write_json
import providers
from snapshot import manifest, verify


def utc():
    return datetime.datetime.now(datetime.UTC).isoformat()


def stop_group(process):
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    try:
        process.wait(timeout=2)
    except subprocess.TimeoutExpired:
        pass
    try:
        os.killpg(process.pid, signal.SIGKILL)
    except ProcessLookupError:
        pass
    process.wait()


def run_one(root, cell, version, stop):
    experiment = read_json(root / "experiment.json")
    run_dir = root / "runs" / cell["run_id"]
    run_dir.mkdir(parents=True, exist_ok=True)
    attempts = list(run_dir.glob("attempt-*"))
    directory = run_dir / f"attempt-{len(attempts) + 1:04}"
    directory.mkdir()
    workspace = directory / "workspace"
    shutil.copytree(root / "snapshot", workspace, symlinks=True)
    expected = read_json(root / "manifest.json")
    if manifest(workspace) != expected:
        raise ValueError("Per-review copy does not match the frozen snapshot")
    args = providers.command(cell, directory, version["executable"])
    record = {
        **cell,
        "attempt": len(attempts) + 1,
        "command": args,
        "harness": version,
        "prompt_sha256": experiment["prompt_sha256"],
        "status": "running",
        "started_at": utc(),
    }
    write_json(directory / "record.json", record)
    print(f"START {cell['run_id']} {cell['model']} {cell['effort']}", flush=True)
    started = time.monotonic()
    process = None
    try:
        with (root / "prompt.txt").open("rb") as prompt, (
            directory / "events.jsonl"
        ).open("wb") as events, (directory / "stderr.txt").open("wb") as errors:
            process = subprocess.Popen(
                args,
                stdin=prompt,
                stdout=events,
                stderr=errors,
                cwd=workspace,
                start_new_session=True,
                env={**os.environ, "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1"},
            )
            record["process_group"] = process.pid
            record["host"] = socket.gethostname()
            write_json(directory / "record.json", record)
            while process.poll() is None:
                if stop.is_set():
                    record["status"] = "interrupted"
                    break
                if (
                    time.monotonic() - started
                    >= experiment["config"]["timeout_seconds"]
                ):
                    record["status"] = "timeout"
                    break
                stop.wait(0.1)
            if record["status"] == "running":
                record["exit_code"] = process.returncode
                record["status"] = "completed" if process.returncode == 0 else "failed"
            stop_group(process)
            process = None
            record["wall_seconds"] = round(time.monotonic() - started, 3)
            record["finished_at"] = utc()
        record["source_unchanged"] = manifest(workspace) == expected
        if not record["source_unchanged"]:
            record["status"] = "source_modified"
        try:
            review, audit = providers.parse(cell["provider"], directory)
            record["usage"] = audit["usage"]
            if record["status"] == "completed":
                write_json(directory / "review.json", review)
                record["review"] = review
        except (ValueError, KeyError, OSError) as error:
            if record["status"] == "completed":
                record["status"] = "invalid_response"
                record["error"] = str(error)
    except Exception as error:
        record["status"] = "failed"
        record["error"] = str(error)
    finally:
        if process is not None:
            stop_group(process)
        record.setdefault("wall_seconds", round(time.monotonic() - started, 3))
        record.setdefault("finished_at", utc())
        for name in ("events.jsonl", "response.txt", "stderr.txt"):
            if (directory / name).exists():
                record[name + "_sha256"] = digest((directory / name).read_bytes())
        write_json(directory / "record.json", record)
    print(
        f"END {cell['run_id']} {record['status']} {record['wall_seconds']:.1f}s",
        flush=True,
    )
    return record


def run(root, retry_failed=False):
    if os.name != "posix":
        raise ValueError(
            "The native runner currently requires Linux, WSL or macOS process groups",
        )
    root = Path(root).resolve()
    with locked(root):
        verify(root)
        experiment = read_json(root / "experiment.json")
        records = latest_runs(root)
        cells = []
        for cell, record in zip(experiment["schedule"], records, strict=True):
            if record["status"] == "running":
                if record.get("host") != socket.gethostname() or not record.get(
                    "process_group",
                ):
                    raise ValueError(
                        "Interrupted launch has unknown process state; inspect its saved attempt before recovery",
                    )
                try:
                    os.killpg(record["process_group"], 0)
                except ProcessLookupError:
                    pass
                else:
                    raise ValueError(
                        f"Review process group {record['process_group']} still exists; inspect and stop it before recovery",
                    )
            if record["status"] == "pending" or (
                retry_failed and record["status"] != "completed"
            ):
                cells.append(cell)
        if not cells:
            print(
                "No pending reviews. Failed/interrupted attempts require --retry-failed.",
            )
            return records
        versions = providers.preflight(cells)
        version_path = root / "harnesses.json"
        previous = read_json(version_path) if version_path.exists() else {}
        for provider, value in versions.items():
            if provider in previous and any(
                value[key] != previous[provider][key]
                for key in ("executable", "version")
            ):
                raise ValueError(
                    "Harness changed since first launch; start a new experiment instead of mixing versions",
                )
        write_json(version_path, {**previous, **versions})
        stop = threading.Event()
        executor = concurrent.futures.ThreadPoolExecutor(
            max_workers=experiment["config"]["concurrency"],
        )
        futures = [
            executor.submit(run_one, root, cell, versions[cell["provider"]], stop)
            for cell in cells
        ]
        try:
            for future in concurrent.futures.as_completed(futures):
                future.result()
        except BaseException:
            stop.set()
            for future in futures:
                future.cancel()
            raise
        finally:
            executor.shutdown(wait=True, cancel_futures=True)
        verify(root)
        return latest_runs(root)
