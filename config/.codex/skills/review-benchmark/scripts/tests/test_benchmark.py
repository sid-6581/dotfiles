"""Behavioral checks with local fake CLIs; no model requests or target test suites."""

import copy
import json
import os
import socket
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import adjudication
import common
import providers
import report
import runner
import snapshot

FAKE = r"""#!/usr/bin/env python3
import json, os, subprocess, sys, time
from pathlib import Path
if '--help' in sys.argv:
 print('--ignore-user-config --ignore-rules --ephemeral --sandbox --output-last-message --json --safe-mode --strict-mcp-config --permission-mode --no-session-persistence --output-format --effort');sys.exit()
if '--version' in sys.argv:
 print('fixture-cli 1.0');sys.exit()
provider=Path(sys.argv[0]).name
model=sys.argv[sys.argv.index('--model')+1]
if model=='fail':
 print('simulated failure',file=sys.stderr);sys.exit(4)
if model=='slow':
 child=subprocess.Popen([sys.executable,'-c','import time; time.sleep(30)'])
 Path('../helper-pid').write_text(str(child.pid))
 time.sleep(30)
if model=='mutate': Path('source/app.py').write_text('mutated\n')
finding={'id':'F1','title':'A <script>literal</script> finding','category':'correctness','kind':'defect','severity':'medium','confidence':'high','file':'source/app.py','line_start':1,'line_end':1,'evidence':'value = 2','scenario':'fixture input','impact':'fixture output','recommendation':'fix fixture','verification':'static inspection'}
review={'summary':'fixture','findings':[] if model=='zero' else [finding],'coverage':[],'checks_performed':['static inspection'],'limitations':[]}
text='not valid JSON' if model=='bad' else json.dumps(review)
if provider=='codex':
 Path(sys.argv[sys.argv.index('--output-last-message')+1]).write_text(text)
 print(json.dumps({'type':'item.completed','item':{'type':'command_execution','command':'cat source/app.py'}}))
 print(json.dumps({'type':'turn.completed','usage':{'input_tokens':10,'output_tokens':20}}))
else:
 print(json.dumps({'type':'assistant','message':{'model':model,'content':[{'type':'tool_use','name':'Read','input':{'file_path':'source/app.py'}}]}}))
 print(json.dumps({'type':'result','result':text,'is_error':False,'usage':{'input_tokens':10},'duration_api_ms':10}))
"""


class BenchmarkTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name)
        self.repo = self.home / "repo"
        self.repo.mkdir()
        self.git("init", "-q")
        self.git("config", "user.name", "Fixture")
        self.git("config", "user.email", "fixture@example.invalid")
        (self.repo / "app.py").write_text("value = 1\n")
        (self.repo / ".gitignore").write_text("ignored.txt\n")
        self.git("add", ".")
        self.git("-c", "core.hooksPath=/dev/null", "commit", "-qm", "fixture base")
        self.base = self.git("rev-parse", "HEAD").strip()
        (self.repo / "app.py").write_text("value = 2\n")
        self.git("add", ".")
        self.git("-c", "core.hooksPath=/dev/null", "commit", "-qm", "fixture head")
        self.bin = self.home / "bin"
        self.bin.mkdir()
        for name in ("codex", "claude"):
            path = self.bin / name
            path.write_text(FAKE)
            path.chmod(0o755)
        self.environment = patch.dict(
            os.environ, {"PATH": str(self.bin) + os.pathsep + os.environ["PATH"]},
        )
        self.environment.start()
        self.addCleanup(self.environment.stop)
        self.number = 0

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.repo), *args], text=True)

    def prepare(self, model="fixture", **values):
        self.number += 1
        config = {
            "scope": "diff",
            "base": self.base,
            "reviewers": [{"provider": "codex", "model": model, "effort": "high"}],
        }
        config.update(values)
        return snapshot.prepare(self.repo, config, self.home / f"run-{self.number}")

    def complete(self, **values):
        root = self.prepare(**values)
        runner.run(root)
        adjudication.collect(root)
        return root

    def verdict(self, root, **values):
        claim = common.read_json(root / "claims.json")[0]["claim_id"]
        row = {
            "claim_id": claim,
            "issue_id": "B001",
            "title": "Fixture root",
            "verdict": "confirmed_defect",
            "severity": "medium",
            "rationale": "source-backed fixture",
            "adjudicator": "test",
            "labels_hidden": False,
            "factual_corrections": [],
            "evidence": [
                {
                    "file": "source/app.py",
                    "line_start": 1,
                    "line_end": 1,
                    "quote": "value = 2",
                },
            ],
        }
        row.update(values)
        path = self.home / "verdict.json"
        common.write_json(path, [row])
        return path

    def test_frozen_diff_ignores_dirty_checkout(self):
        (self.repo / "app.py").write_text("dirty\n")
        root = self.prepare()
        self.assertEqual((root / "snapshot/source/app.py").read_text(), "value = 2\n")
        self.assertEqual((root / "snapshot/baseline/app.py").read_text(), "value = 1\n")
        self.assertEqual(
            common.read_json(root / "snapshot/scope.json")["changed"], ["app.py"],
        )
        self.assertTrue(
            common.read_json(root / "experiment.json")["dirty_checkout_ignored"],
        )
        self.assertEqual((self.repo / "app.py").read_text(), "dirty\n")

    def test_worktree_staged_deleted_untracked_and_ignored(self):
        (self.repo / "app.py").unlink()
        (self.repo / "new.py").write_text("new\n")
        (self.repo / "ignored.txt").write_text("private\n")
        root = self.prepare(scope="worktree", include_untracked=True)
        self.assertFalse((root / "snapshot/source/app.py").exists())
        self.assertTrue((root / "snapshot/source/new.py").exists())
        self.assertFalse((root / "snapshot/source/ignored.txt").exists())
        self.assertEqual(
            common.read_json(root / "snapshot/scope.json")["removed"], ["app.py"],
        )

    def test_exclusions_apply_to_patch(self):
        root = self.prepare(exclude=["app.py"])
        self.assertNotIn("value = ", (root / "snapshot/changes.patch").read_text())
        self.assertFalse((root / "snapshot/source/app.py").exists())

    def test_export_ignore_does_not_remove_review_source(self):
        (self.repo / ".gitattributes").write_text("app.py export-ignore\n")
        self.git("add", ".")
        self.git(
            "-c", "core.hooksPath=/dev/null", "commit", "-qm", "fixture attributes",
        )
        self.assertTrue((self.prepare() / "snapshot/source/app.py").exists())

    def test_symlinks_and_escape_rejection(self):
        (self.repo / "alias.py").symlink_to("app.py")
        root = self.prepare(scope="worktree", include_untracked=True)
        self.assertTrue((root / "snapshot/source/alias.py").is_symlink())
        (self.repo / "outside").symlink_to("/etc/passwd")
        with self.assertRaisesRegex(ValueError, "escapes"):
            self.prepare(scope="worktree", include_untracked=True)

    def test_reject_output_in_target_and_changed_snapshot(self):
        with self.assertRaisesRegex(ValueError, "outside"):
            snapshot.prepare(
                self.repo,
                {
                    "scope": "tree",
                    "reviewers": [
                        {"provider": "codex", "model": "fixture", "effort": "high"},
                    ],
                },
                self.repo / "output",
            )
        root = self.prepare()
        (root / "snapshot/source/app.py").write_text("changed")
        with self.assertRaisesRegex(ValueError, "Frozen source changed"):
            runner.run(root)

    def test_end_to_end_providers_repetition_and_resume(self):
        reviewers = [
            {"provider": p, "model": "fixture", "effort": "high"}
            for p in ("codex", "claude")
        ]
        root = self.complete(reviewers=reviewers, repetitions=2, concurrency=2)
        self.assertEqual(len(common.latest_runs(root)), 4)
        responses = {
            p: p.read_bytes() for p in root.glob("runs/*/attempt-*/response.txt")
        }
        runner.run(root)
        self.assertEqual(len(list(root.glob("runs/*/attempt-*/record.json"))), 4)
        self.assertTrue(all(p.read_bytes() == value for p, value in responses.items()))
        claims = common.read_json(root / "claims.json")
        self.assertEqual(len(claims), 4)
        self.assertNotIn("provider", json.dumps(claims))
        adjudication.collect(root)
        self.assertEqual(common.read_json(root / "claims.json"), claims)
        self.assertEqual(len({r["prompt_sha256"] for r in common.latest_runs(root)}), 1)
        self.assertEqual((self.repo / "app.py").read_text(), "value = 2\n")

    def test_failed_attempt_requires_explicit_retry(self):
        root = self.prepare(model="fail")
        self.assertEqual(runner.run(root)[0]["status"], "failed")
        runner.run(root)
        self.assertEqual(len(list(root.glob("runs/*/attempt-*"))), 1)
        runner.run(root, retry_failed=True)
        self.assertEqual(len(list(root.glob("runs/*/attempt-*"))), 2)

    def test_invalid_and_mutating_reviewers_are_not_successes(self):
        for model, status in [
            ("bad", "invalid_response"),
            ("mutate", "source_modified"),
        ]:
            root = self.prepare(model=model)
            self.assertEqual(runner.run(root)[0]["status"], status)
            self.assertEqual(adjudication.collect(root), [])
            audit = common.read_json(next(root.glob("runs/*/attempt-*/audit.json")))
            self.assertTrue(audit["tool_calls"])
            if model == "bad":
                self.assertIn("not valid JSON", report.render(root).read_text())
            snapshot.verify(root)

    def test_recovery_refuses_a_live_review_process_group(self):
        root = self.prepare()
        cell = common.read_json(root / "experiment.json")["schedule"][0]
        child = subprocess.Popen(
            [sys.executable, "-c", "import time; time.sleep(30)"],
            start_new_session=True,
        )
        self.addCleanup(child.wait)
        self.addCleanup(child.terminate)
        record = {
            **cell,
            "status": "running",
            "attempt": 1,
            "host": socket.gethostname(),
            "process_group": child.pid,
        }
        common.write_json(root / "runs/R0001/attempt-0001/record.json", record)
        with self.assertRaisesRegex(ValueError, "process group .* still exists"):
            runner.run(root, retry_failed=True)

    def test_reject_invalid_config_before_preparing_files(self):
        for values in (
            {"include_untracked": "false"},
            {"reviewers": "codex"},
            {"instructions": []},
        ):
            with self.assertRaises(ValueError):
                self.prepare(**values)

    def test_new_worktree_submodule_cannot_be_silently_omitted(self):
        self.git(
            "update-index",
            "--add",
            "--cacheinfo",
            "160000," + self.base + ",dependency",
        )
        with self.assertRaisesRegex(ValueError, "Submodule"):
            self.prepare(scope="worktree")

    def test_timeout_stops_helper_process(self):
        root = self.prepare(model="slow", timeout_seconds=1)
        self.assertEqual(runner.run(root)[0]["status"], "timeout")
        pid = next(root.glob("runs/*/attempt-*/helper-pid")).read_text()
        status = Path("/proc") / pid / "status"
        if status.exists():
            self.assertIn("Z (zombie)", status.read_text())

    def test_verdict_validation_and_revision_history(self):
        root = self.complete()
        path = self.verdict(root)
        adjudication.adjudicate(root, path)
        original = common.read_json(root / "adjudications.json")
        bad = copy.deepcopy(original)
        bad[0]["evidence"][0]["quote"] = "invented"
        common.write_json(path, bad)
        with self.assertRaisesRegex(ValueError, "does not match"):
            adjudication.adjudicate(root, path)
        self.assertEqual(common.read_json(root / "adjudications.json"), original)
        adjudication.adjudicate(root, self.verdict(root, verdict="supported_concern"))
        self.assertEqual(len(list((root / "adjudication-history").glob("*.json"))), 2)

    def test_report_preserves_data_and_escapes_untrusted_text(self):
        root = self.complete()
        adjudication.adjudicate(root, self.verdict(root))
        text = report.render(root).read_text()
        self.assertIn("Provisional", text)
        self.assertNotIn("<script>literal</script>", text)
        self.assertIn("&lt;script&gt;literal&lt;/script&gt;", text)
        self.assertIn("value = 2", text)
        audit_file = self.home / "audit.json"
        common.write_json(
            audit_file,
            [
                {
                    "run_id": "R0001",
                    "attempt": 1,
                    "status": "checked",
                    "notes": "Inspected fixture read command",
                },
            ],
        )
        adjudication.audit(root, audit_file)
        self.assertIn("Complete and audited", report.render(root).read_text())
        current = common.read_json(root / "protocol-audits.json")
        current["R0001"]["attempt"] = 0
        common.write_json(root / "protocol-audits.json", current)
        self.assertIn("Provisional", report.render(root).read_text())

    def test_sorting_metadata_and_static_overlap_are_preserved(self):
        root = self.complete()
        adjudication.adjudicate(root, self.verdict(root))
        text = report.render(root).read_text()
        self.assertIn('id="run-sort"', text)
        self.assertIn('id="issue-sort"', text)
        self.assertIn('data-run-list="findings"', text)
        self.assertIn('data-run-list="duration"', text)
        self.assertIn('data-confirmed="1"', text)
        self.assertIn('data-coverage="1"', text)
        self.assertIn('aria-label="R0001: confirmed"', text)
        self.assertNotIn("<script src=", text)

    def test_zero_findings_have_undefined_accuracy(self):
        root = self.complete(model="zero")
        runs, pool = report.metrics(common.latest_runs(root), [], {})
        self.assertTrue(runs[0]["fully_adjudicated"])
        self.assertIsNone(runs[0]["accuracy"])
        self.assertEqual(pool, set())

    def test_duplicate_root_credit_and_partial_scores(self):
        run = {
            "run_id": "R1",
            "status": "completed",
            "review": {"findings": [{}, {}]},
            "wall_seconds": 60,
        }
        mapping = {"C1": {"run_id": "R1"}, "C2": {"run_id": "R1"}}
        row = {
            "claim_id": "C1",
            "issue_id": "B1",
            "verdict": "confirmed_defect",
            "severity": "high",
        }
        values, pool = report.metrics([run], [row], mapping)
        self.assertFalse(values[0]["fully_adjudicated"])
        self.assertIsNone(values[0]["yield_per_minute"])
        values, pool = report.metrics([run], [row, {**row, "claim_id": "C2"}], mapping)
        self.assertEqual(values[0]["counts"]["confirmed_defect"], 1)
        self.assertEqual(values[0]["high"], 1)
        self.assertEqual(values[0]["yield_per_minute"], 1)

    def test_lock_prevents_overlapping_execution(self):
        root = self.prepare()
        with common.locked(root):
            with self.assertRaisesRegex(ValueError, "locked"):
                runner.run(root)
            with self.assertRaisesRegex(ValueError, "still running"):
                common.unlock(root)
        self.assertFalse((root / ".lock").exists())


if __name__ == "__main__":
    unittest.main()
