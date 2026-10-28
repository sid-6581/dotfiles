#!/usr/bin/env python3
"""Run a comparative review from a manually invoked Codex skill."""

import argparse
import json
from pathlib import Path
import subprocess
import sys

import adjudication
from common import latest_runs, read_json, unlock
import providers
import report
import runner
import snapshot


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    prepare = commands.add_parser(
        "prepare",
        help="freeze a repository and an explicit model matrix; no model calls",
    )
    prepare.add_argument("--repo", type=Path, default=Path.cwd())
    prepare.add_argument("--config", type=Path, required=True)
    prepare.add_argument("--output", type=Path)
    doctor = commands.add_parser(
        "doctor", help="check installed CLI options and versions without model calls",
    )
    doctor.add_argument("--config", type=Path, required=True)
    for name in (
        "run",
        "resume",
        "collect",
        "adjudicate",
        "audit",
        "report",
        "status",
        "unlock",
        "add-evidence",
    ):
        command = commands.add_parser(name)
        command.add_argument("experiment", type=Path)
        if name in ("run", "resume"):
            command.add_argument(
                "--retry-failed",
                action="store_true",
                help="append attempts for failed/interrupted reviews; retains earlier attempts",
            )
        if name in ("adjudicate", "audit", "add-evidence"):
            command.add_argument("--file", type=Path, required=True)
        if name == "add-evidence":
            command.add_argument(
                "--name",
                required=True,
                help="new relative name under the experiment evidence/ directory",
            )
    args = parser.parse_args(argv)
    try:
        if args.command == "prepare":
            print(
                snapshot.prepare(
                    args.repo.resolve(), read_json(args.config), args.output,
                ),
            )
        elif args.command == "doctor":
            print(
                json.dumps(
                    providers.preflight(read_json(args.config)["reviewers"]), indent=2,
                ),
            )
        else:
            root = args.experiment.expanduser().resolve()
            if args.command in ("run", "resume"):
                rows = runner.run(root, args.retry_failed)
                return 0 if all(r["status"] == "completed" for r in rows) else 1
            if args.command == "collect":
                rows = adjudication.collect(root)
                print(f"Exported {len(rows)} claims to {root / 'claims.json'}")
            elif args.command == "adjudicate":
                print(
                    f"Saved {len(adjudication.adjudicate(root, args.file))} adjudicated roots/submissions",
                )
            elif args.command == "audit":
                adjudication.audit(root, args.file)
                print(root / "protocol-audits.json")
            elif args.command == "report":
                print(report.render(root))
            elif args.command == "status":
                print(
                    json.dumps(
                        [
                            {
                                k: r.get(k)
                                for k in (
                                    "run_id",
                                    "model",
                                    "effort",
                                    "repetition",
                                    "status",
                                    "attempt",
                                    "wall_seconds",
                                )
                            }
                            for r in latest_runs(root)
                        ],
                        indent=2,
                    ),
                )
            elif args.command == "unlock":
                unlock(root)
            elif args.command == "add-evidence":
                print(adjudication.add_evidence(root, args.file, args.name))
        return 0
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        print(f"review-benchmark: {error}", file=sys.stderr)
        return 2
    except KeyboardInterrupt:
        print(
            "Interrupted. Completed attempts are preserved; inspect status before resuming.",
            file=sys.stderr,
        )
        return 130


if __name__ == "__main__":
    sys.exit(main())
