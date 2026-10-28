"""Export anonymous claims and validate explicit, evidence-backed verdicts."""

import datetime
from pathlib import Path
import shutil

from common import (
    SEVERITIES,
    VERDICTS,
    inside,
    latest_runs,
    locked,
    read_json,
    write_json,
)
from snapshot import verify


def collect(root):
    with locked(root):
        verify(root)
        mapping_path = root / "claim-map.json"
        mapping = read_json(mapping_path) if mapping_path.exists() else {}
        reverse = {
            (value["run_id"], value["finding_id"]): key
            for key, value in mapping.items()
        }
        claims = []
        for run in latest_runs(root):
            for finding in (
                run.get("review", {}).get("findings", [])
                if run["status"] == "completed"
                else []
            ):
                pair = (run["run_id"], finding["id"])
                if pair not in reverse:
                    claim_id = f"C{len(mapping) + 1:04}"
                    mapping[claim_id] = {
                        "run_id": pair[0],
                        "finding_id": pair[1],
                        "attempt": run["attempt"],
                    }
                    reverse[pair] = claim_id
                if mapping[reverse[pair]]["attempt"] != run["attempt"]:
                    raise ValueError(
                        "A previously collected review was replaced; start a new experiment",
                    )
                claims.append(
                    {
                        "claim_id": reverse[pair],
                        "finding": {k: v for k, v in finding.items() if k != "id"},
                    },
                )
        write_json(mapping_path, mapping)
        write_json(root / "claims.json", claims)
        return claims


def quote(root, evidence):
    name = evidence.get("file", "")
    if not isinstance(name, str) or Path(name).parts[:1] not in (
        ("source",),
        ("baseline",),
        ("evidence",),
    ):
        raise ValueError(
            "Evidence paths must start with source/, baseline/ or evidence/",
        )
    base = root if name.startswith("evidence/") else root / "snapshot"
    path = inside(base, name)
    start, end = evidence.get("line_start"), evidence.get("line_end")
    if type(start) is not int or type(end) is not int or start < 1 or end < start:
        raise ValueError("Invalid evidence range")
    lines = path.read_text(encoding="utf-8").splitlines()
    if end > len(lines):
        raise ValueError(f"Evidence range exceeds {name}")
    text = "\n".join(lines[start - 1 : end])
    if evidence.get("quote") != text:
        raise ValueError(f"Evidence quote does not match {name}:{start}-{end}")
    return text


def adjudicate(root, path):
    updates = read_json(path)
    if not isinstance(updates, list) or not updates:
        raise ValueError("Supply a nonempty array of adjudications")
    with locked(root):
        verify(root)
        mapping = read_json(root / "claim-map.json")
        for row in updates:
            if row.get("claim_id") not in mapping:
                raise ValueError(f"Unknown claim: {row.get('claim_id')}")
            for field in ("issue_id", "title", "rationale", "adjudicator"):
                if not isinstance(row.get(field), str) or not row[field].strip():
                    raise ValueError(f"Adjudication requires {field}")
            if (
                row.get("verdict") not in VERDICTS
                or row.get("severity") not in SEVERITIES
            ):
                raise ValueError("Unknown verdict or severity")
            if type(row.get("labels_hidden")) is not bool:
                raise ValueError(
                    "Record whether reviewer labels were hidden from the adjudicator",
                )
            if not isinstance(row.get("factual_corrections"), list) or not all(
                isinstance(x, str) for x in row["factual_corrections"]
            ):
                raise ValueError("factual_corrections must be a list of strings")
            if not isinstance(row.get("evidence"), list) or not row["evidence"]:
                raise ValueError(
                    "Every adjudication needs source evidence, including unresolved premises",
                )
            for evidence in row["evidence"]:
                quote(root, evidence)
        keys = [(row["claim_id"], row["issue_id"]) for row in updates]
        if len(keys) != len(set(keys)):
            raise ValueError("Duplicate claim/issue pair")
        current_path = root / "adjudications.json"
        current = read_json(current_path) if current_path.exists() else []
        replaced = {row["claim_id"] for row in updates}
        rows = [row for row in current if row["claim_id"] not in replaced] + updates
        titles = {}
        severities = {}
        for row in rows:
            issue = row["issue_id"]
            if issue in titles and titles[issue] != row["title"]:
                raise ValueError(f"Use one canonical title for {issue}")
            titles[issue] = row["title"]
            if row["verdict"] == "confirmed_defect":
                if issue in severities and severities[issue] != row["severity"]:
                    raise ValueError(f"Use consistent confirmed severity for {issue}")
                severities[issue] = row["severity"]
        history = root / "adjudication-history"
        history.mkdir(exist_ok=True)
        revision = len(list(history.glob("*.json"))) + 1
        write_json(
            history / f"{revision:04}.json",
            {
                "updated_at": datetime.datetime.now(datetime.UTC).isoformat(),
                "rows": rows,
            },
        )
        write_json(current_path, rows)
        return rows


def add_evidence(root, source, name):
    with locked(root):
        destination = inside(root / "evidence", name)
        if destination.exists():
            raise ValueError("Evidence is immutable; choose a new name")
        source.read_text(encoding="utf-8")
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, destination)
        return destination


def audit(root, path):
    updates = read_json(path)
    if not isinstance(updates, list):
        raise ValueError("Audit input must be an array")
    with locked(root):
        runs = {r["run_id"]: r for r in latest_runs(root)}
        destination = root / "protocol-audits.json"
        current = read_json(destination) if destination.exists() else {}
        for entry in updates:
            run = runs.get(entry.get("run_id"))
            if not run or entry.get("attempt") != run.get("attempt"):
                raise ValueError("Audit must identify a current run and attempt")
            if entry.get("status") not in ("checked", "deviation", "unresolved"):
                raise ValueError("Unknown audit status")
            if not isinstance(entry.get("notes"), str) or not entry["notes"].strip():
                raise ValueError(
                    "Audit needs notes describing the inspected execution evidence",
                )
            current[entry["run_id"]] = entry
        write_json(destination, current)
