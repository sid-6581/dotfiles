"""Static, portable HTML from saved records. Never invokes a model."""

from collections import defaultdict
import html
import json
from statistics import median

from common import SEVERITIES, SKILL, VERDICTS, latest_runs, locked, read_json
from snapshot import verify
from adjudication import quote


def esc(value):
    return html.escape(str(value), quote=True)


def duration(seconds):
    if seconds is None:
        return "—"
    minutes, remainder = divmod(round(seconds), 60)
    return f"{minutes}m {remainder:02}s"


SORT_FIELDS = {
    "confirmed": "Confirmed defects",
    "high": "High / critical defects",
    "concerns": "Design concerns",
    "refuted": "Refuted claims",
    "unresolved": "Unresolved claims",
    "corrections": "Corrected claims",
    "seconds": "Review duration",
    "yield": "Defects per minute",
    "accuracy": "Accuracy",
    "model": "Model",
    "effort": "Effort",
    "id": "Run ID",
}


def sorting_controls(prefix, fields):
    options = "".join(
        f'<option value="{key}">{esc(label)}</option>' for key, label in fields.items()
    )
    return f'<div class="sort-controls" hidden><label>Sort by <select id="{prefix}-sort">{options}</select></label><label>Order <select id="{prefix}-direction"><option value="desc">Descending</option><option value="asc">Ascending</option></select></label></div>'


def sort_attributes(run):
    values = {
        "id": run["run_id"],
        "model": run["model"],
        "effort": ("minimal", "low", "medium", "high", "xhigh", "max").index(
            run["effort"],
        ),
        "confirmed": run["counts"]["confirmed_defect"],
        "high": run["high"],
        "concerns": run["counts"]["supported_concern"],
        "refuted": run["counts"]["refuted"],
        "unresolved": run["counts"]["unresolved"],
        "corrections": run["corrected_claims"],
        "seconds": run.get("wall_seconds"),
        "yield": run["yield_per_minute"],
        "accuracy": run["accuracy"],
    }
    # Missing and unfinished results must sort after observed values, never as zero successes.
    if run["status"] != "completed":
        for field in (
            "confirmed",
            "high",
            "concerns",
            "refuted",
            "unresolved",
            "corrections",
            "accuracy",
        ):
            values[field] = None
    return " ".join(
        f'data-{key}="{esc(value) if value is not None else ""}"'
        for key, value in values.items()
    )


def overlap(runs, rows, mapping, pool):
    parts = [
        sorting_controls(
            "issue",
            {"coverage": "Discovery count", "severity": "Severity", "id": "Issue ID"},
        ),
    ]
    parts.append(
        '<div class="scroll"><table id="overlap"><caption>Confirmed defects found by each review. A dash means no confirmed finding here, not proof that the issue was absent.</caption><thead><tr><th scope="col">Issue / severity / discovery count</th>',
    )
    for run in runs:
        parts.append(
            f'<th scope="col" data-run-id="{esc(run["run_id"])}" title="{esc(run["model"])} · {esc(run["effort"])}">{esc(run["run_id"])}</th>',
        )
    parts.append("</tr></thead><tbody>")
    for issue in sorted(pool):
        group = [
            row
            for row in rows
            if row["issue_id"] == issue and row["verdict"] == "confirmed_defect"
        ]
        found = {mapping[row["claim_id"]]["run_id"] for row in group}
        severity = group[0]["severity"]
        parts.append(
            f'<tr data-id="{esc(issue)}" data-coverage="{len(found)}" data-severity="{SEVERITIES.index(severity)}"><th scope="row"><a href="#issue-{esc(issue)}">{esc(issue)} · {esc(group[0]["title"])}</a><br><span class="fine">{esc(severity)} · {len(found)}/{len(runs)} reviews</span></th>',
        )
        for run in runs:
            hit = run["run_id"] in found
            parts.append(
                f'<td data-run-id="{esc(run["run_id"])}" class="{"hit" if hit else "miss"}" aria-label="{esc(run["run_id"])}: {"confirmed" if hit else "not confirmed"}">{"●" if hit else "—"}</td>',
            )
        parts.append("</tr>")
    parts.append("</tbody></table></div>")
    if not pool:
        parts.append("<p>No confirmed defects have been adjudicated yet.</p>")
    return "\n".join(parts)


def metrics(runs, rows, mapping):
    pool = {r["issue_id"] for r in rows if r["verdict"] == "confirmed_defect"}
    result = []
    for run in runs:
        claims = [r for r in rows if mapping[r["claim_id"]]["run_id"] == run["run_id"]]
        counts = {
            verdict: len({r["issue_id"] for r in claims if r["verdict"] == verdict})
            for verdict in VERDICTS
        }
        assessed = {r["claim_id"] for r in claims}
        submitted = {
            key for key, value in mapping.items() if value["run_id"] == run["run_id"]
        }
        complete = (
            run["status"] == "completed"
            and len(submitted) == len(run["review"]["findings"])
            and assessed == submitted
        )
        resolved = (
            counts["confirmed_defect"] + counts["supported_concern"] + counts["refuted"]
        )
        seconds = run.get("wall_seconds")
        result.append(
            {
                **run,
                "counts": counts,
                "assessed": len(assessed),
                "fully_adjudicated": complete,
                "high": len(
                    {
                        r["issue_id"]
                        for r in claims
                        if r["verdict"] == "confirmed_defect"
                        and r["severity"] in ("high", "critical")
                    },
                ),
                "corrected_claims": len(
                    {r["claim_id"] for r in claims if r.get("factual_corrections")},
                ),
                "accuracy": (
                    (counts["confirmed_defect"] + counts["supported_concern"])
                    / resolved
                    if resolved
                    else None
                ),
                "yield_per_minute": (
                    counts["confirmed_defect"] * 60 / seconds
                    if seconds and complete
                    else None
                ),
                "confirmed_roots": sorted(
                    {
                        r["issue_id"]
                        for r in claims
                        if r["verdict"] == "confirmed_defect"
                    },
                ),
            },
        )
    return result, pool


def render(root):
    with locked(root):
        verify(root)
        experiment = read_json(root / "experiment.json")
        mapping = (
            read_json(root / "claim-map.json")
            if (root / "claim-map.json").exists()
            else {}
        )
        rows = (
            read_json(root / "adjudications.json")
            if (root / "adjudications.json").exists()
            else []
        )
        audits = (
            read_json(root / "protocol-audits.json")
            if (root / "protocol-audits.json").exists()
            else {}
        )
        for row in rows:
            for evidence in row["evidence"]:
                quote(root, evidence)
        runs, pool = metrics(latest_runs(root), rows, mapping)
        audits = {
            run["run_id"]: audits[run["run_id"]]
            for run in runs
            if audits.get(run["run_id"], {}).get("attempt") == run.get("attempt")
            and run["run_id"] in audits
        }
        completed = sum(r["status"] == "completed" for r in runs)
        unassessed = sum(
            len(r.get("review", {}).get("findings", [])) - r["assessed"] for r in runs
        )
        final = all(r["fully_adjudicated"] for r in runs) and all(
            audits.get(r["run_id"], {}).get("status") == "checked" for r in runs
        )
        sections = [
            f'<p class="notice">{"Complete and audited" if final else "Provisional / incomplete or flagged"} · {completed}/{len(runs)} reviews completed · {unassessed} submitted findings awaiting adjudication · {len(pool)} distinct confirmed roots.</p>',
        ]
        sections.append(
            "<h2>Results</h2><p>One credit per root cause per review. Design concerns and factual corrections are separate from confirmed defects. Failed or unfinished reviews are not zero-finding successes.</p>",
        )
        sections.append(sorting_controls("run", SORT_FIELDS))
        sections.append(
            '<p class="sort-help" hidden>Review sorting updates both graphs, the results table and overlap columns. Issue sorting updates overlap rows. Missing values stay last.</p><p id="sort-status" class="fine" role="status" aria-live="polite"></p>',
        )
        maximum = max((sum(r["counts"].values()) for r in runs), default=1) or 1
        colors = {
            "confirmed_defect": "#177d70",
            "supported_concern": "#5578ad",
            "refuted": "#bc453e",
            "unresolved": "#b78620",
        }
        sections.append(
            '<div class="legend">'
            + "".join(
                f'<span><i style="background:{color}"></i>{esc(name.replace("_", " "))}</span>'
                for name, color in colors.items()
            )
            + "</div>",
        )
        sections.append('<div data-run-list="findings">')
        for run in runs:
            label = f"{run['run_id']} · {run['model']} · {run['effort']} · repeat {run['repetition']}"
            if run["status"] != "completed":
                label += " · " + run["status"]
            elif not run["fully_adjudicated"]:
                label += " · partial scoring"
            sections.append(
                f'<div class="chart-row" data-run-id="{esc(run["run_id"])}"><a href="#{esc(run["run_id"])}">{esc(label)}</a><div class="bar">'
                + "".join(
                    f'<span style="width:{run["counts"][name] / maximum * 100:.3f}%;background:{color}" title="{esc(name)}: {run["counts"][name]}">{run["counts"][name] or ""}</span>'
                    for name, color in colors.items()
                    if run["counts"][name]
                )
                + "</div></div>",
            )
        sections.append(
            '</div><div class="scroll"><table id="results"><thead><tr><th>Run / model / effort</th><th>Confirmed</th><th>High</th><th>Design</th><th>Refuted</th><th>Unresolved</th><th>Corrected claims</th><th>Time</th><th>Defects/min</th><th>Accuracy</th><th>Status / audit</th></tr></thead><tbody data-run-list="results">',
        )
        for run in runs:
            score = run["yield_per_minute"]
            accuracy = run["accuracy"]
            cells = [
                run["run_id"] + " · " + run["model"] + " · " + run["effort"],
                run["counts"]["confirmed_defect"],
                run["high"],
                run["counts"]["supported_concern"],
                run["counts"]["refuted"],
                run["counts"]["unresolved"],
                run["corrected_claims"],
                duration(run.get("wall_seconds")),
                f"{score:.2f}" if score is not None else "—",
                f"{accuracy:.0%}" if accuracy is not None else "—",
                run["status"]
                + (" / partial scoring" if not run["fully_adjudicated"] else "")
                + " / "
                + audits.get(run["run_id"], {}).get("status", "audit pending"),
            ]
            if run["status"] != "completed":
                cells[1:7] = ["—"] * 6
            sections.append(
                f'<tr data-run-id="{esc(run["run_id"])}" {sort_attributes(run)}>'
                + "".join(f"<td>{esc(c)}</td>" for c in cells)
                + "</tr>",
            )
        sections.append(
            '</tbody></table></div><p class="fine">Accuracy = (confirmed + supported concerns) / (confirmed + supported concerns + refuted). Unresolved claims are excluded. An empty denominator is undefined. Counts credit roots, not every supporting assertion. Corrected claims count submissions with explicit factual corrections.</p>',
        )
        sections.append(
            "<h2>Review duration</h2><p>Wall time includes process startup, native retries and termination cleanup; snapshot copying, queue wait and fact checking are excluded. Concurrency and provider conditions affect these observations.</p>",
        )
        longest = max((r.get("wall_seconds") or 0 for r in runs), default=1) or 1
        sections.append('<div data-run-list="duration">')
        for run in runs:
            seconds = run.get("wall_seconds")
            sections.append(
                f'<div class="chart-row" data-run-id="{esc(run["run_id"])}"><span>{esc(run["run_id"])} · {esc(run["model"])} · {esc(run["effort"])} · {duration(seconds)}</span><div class="bar"><span style="background:#5578ad;width:{(seconds or 0) / longest * 100:.3f}%"></span></div></div>',
            )
        sections.append("</div>")
        groups = defaultdict(list)
        for run in runs:
            groups[(run["provider"], run["model"], run["effort"])].append(run)
        sections.append(
            '<h2>Repeated runs</h2><div class="scroll"><table><tr><th>Configuration</th><th>Fully adjudicated / planned</th><th>Confirmed median [min–max]</th><th>Time median [min–max]</th></tr>',
        )
        for key, group in groups.items():
            good = [r for r in group if r["fully_adjudicated"]]
            counts = [r["counts"]["confirmed_defect"] for r in good]
            seconds = [
                r["wall_seconds"] for r in good if r.get("wall_seconds") is not None
            ]
            count_text = (
                f"{median(counts):g} [{min(counts)}–{max(counts)}]" if counts else "—"
            )
            time_text = (
                f"{duration(median(seconds))} [{duration(min(seconds))}–{duration(max(seconds))}]"
                if seconds
                else "—"
            )
            sections.append(
                f'<tr><td>{esc(" · ".join(key))}</td><td>{len(good)}/{len(group)}</td><td>{count_text}</td><td>{time_text}</td></tr>',
            )
        sections.append(
            '</table></div><p class="fine">These are descriptive ranges, not confidence intervals or significance tests. Single runs cannot establish consistency. Model and effort names are native settings, not matched reasoning budgets across providers.</p>',
        )
        sections.append(
            "<h2>Overlap and fact checks</h2><p>Discovery coverage uses only the union found here; it is not true recall. Expand each root to inspect its submissions and evidence.</p>",
        )
        sections.append(overlap(runs, rows, mapping, pool))
        for issue in sorted({r["issue_id"] for r in rows}):
            group = [r for r in rows if r["issue_id"] == issue]
            found = sorted(
                {
                    mapping[r["claim_id"]]["run_id"]
                    for r in group
                    if r["verdict"] == "confirmed_defect"
                },
            )
            sections.append(
                f'<details id="issue-{esc(issue)}"><summary>{esc(issue)} · {esc(group[0]["title"])}</summary><p>Confirmed by: {esc(", ".join(found) or "none")}</p>',
            )
            for row in group:
                sections.append(
                    f'<article><h3>{esc(row["claim_id"])} · {esc(mapping[row["claim_id"]]["run_id"])} · {esc(row["verdict"])} / {esc(row["severity"])}</h3><p>{esc(row["rationale"])}</p><p class="fine">Adjudicator: {esc(row["adjudicator"])} · Labels hidden: {esc(row["labels_hidden"])}</p>',
                )
                if row["factual_corrections"]:
                    sections.append(
                        "<p><b>Corrections:</b></p><ul>"
                        + "".join(
                            f"<li>{esc(c)}</li>" for c in row["factual_corrections"]
                        )
                        + "</ul>",
                    )
                for evidence in row["evidence"]:
                    sections.append(
                        f'<details><summary>{esc(evidence["file"])}:{evidence["line_start"]}–{evidence["line_end"]}</summary><pre><code>{esc(evidence["quote"])}</code></pre></details>',
                    )
                sections.append("</article>")
            sections.append("</details>")
        sections.append("<h2>Original reviews and execution</h2>")
        for run in runs:
            safe_record = {
                k: v for k, v in run.items() if k not in ("review", "command")
            }
            response_path = (
                root
                / "runs"
                / run["run_id"]
                / f"attempt-{run.get('attempt', 0):04}"
                / "response.txt"
            )
            response = (
                response_path.read_text(encoding="utf-8", errors="replace")
                if response_path.exists()
                else json.dumps(run.get("review"), ensure_ascii=False, indent=2)
            )
            sections.append(
                f'<details id="{esc(run["run_id"])}"><summary>{esc(run["run_id"])} · {esc(run["model"])} · {esc(run["effort"])}</summary><h3>Execution metadata</h3><pre>{esc(json.dumps(safe_record, ensure_ascii=False, indent=2))}</pre><h3>Protocol assessment</h3><pre>{esc(json.dumps(audits.get(run["run_id"], {"status": "pending"}), ensure_ascii=False, indent=2))}</pre><h3>Original response</h3><pre>{esc(response)}</pre></details>',
            )
        sections.append(
            "<h2>Method</h2><p>Source-backed AI-assisted adjudication is fallible and does not establish exhaustive coverage. Reviewer labels are removed from exported claim metadata, but prior adjudicator context and identifying prose can still reveal them. Native harnesses and tool restrictions differ. No prices are inferred from token counts. Full provider event streams remain private local working evidence and are not embedded here.</p>",
        )
        sections.append(
            f'<details><summary>Resolved experiment</summary><pre>{esc(json.dumps(experiment, ensure_ascii=False, indent=2))}</pre></details><details><summary>Identical review prompt</summary><pre>{esc((root / "prompt.txt").read_text())}</pre></details>',
        )
        page = (
            (SKILL / "assets/report.html")
            .read_text()
            .replace("@@TITLE@@", esc("Review Benchmark · " + experiment["id"]))
            .replace("@@CONTENT@@", "\n".join(sections))
        )
        (root / "report.html").write_text(page, encoding="utf-8")
        return root / "report.html"
