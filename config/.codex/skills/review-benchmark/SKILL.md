---
name: review-benchmark
description: "Run a manually requested comparison of code reviewers in the current repository, with identical instructions, measured durations, evidence-backed adjudication, and a portable HTML report."
---

# Review Benchmark

Use this skill when the user explicitly invokes `$review-benchmark` in a Codex session. Use that session's repository as the target, not the skill's dotfiles repository. Run the workflow in this session; do not create another chat or a schedule. The skill is configured for explicit invocation only.

## Configure the experiment

Resolve the repository from the session's working directory with `git rev-parse --show-toplevel`. Infer scope and reviewer choices from the user's request and established context. If missing, ask one concise question for the review scope and exact model/effort combinations before launching reviewers. Do not silently reuse the historical Hawkeye matrix or select substitutes. A branch diff needs an explicit base; uncommitted changes use worktree scope; a full audit uses tree scope.

Read [configuration.md](references/configuration.md) for the JSON configuration and commands. Save the configuration outside the reviewed repository. Keep the shared review instructions identical across every cell. Add relevant repository guidance and requested review priorities to `instructions`; ports are an optional use case, not a default assumption. Tests are assumed passing: existing suites, builds and benchmarks are prohibited by the bundled prompt; reviewers may perform isolated checks for specific hypotheses.

Use one repetition and concurrency one unless the user requests otherwise. Explain the planned matrix and total number of reviews before launch, without asking again when already authorized. For stronger comparisons, suggest repetitions without silently multiplying model calls.

## Execute and preserve results

Locate `scripts/benchmark.py` relative to this SKILL.md. Commands below use `SCRIPT` for its absolute path and `RUN` for the experiment directory printed by prepare; always use quoted paths. Run `python "$SCRIPT" doctor --config "$CONFIG"`, then `prepare --repo "$REPO" --config "$CONFIG"`. Preparation freezes tracked source and instructions without model calls or target-repository edits. The default persistent output is under the user's data directory, outside the target checkout.

Run `python "$SCRIPT" run "$RUN"`. Keep the user informed while it executes. After interruption, inspect `status "$RUN"`; `resume "$RUN"` runs only pending cells. Failed, timed-out, invalid or interrupted attempts require `--retry-failed`, used only when the user authorizes another attempt. Earlier attempts remain saved. A stale lock can be recovered with `unlock "$RUN"` only after its recorded owner has stopped. Do not alter saved prompts, sources or results to make a run pass.

Provider options can be checked locally, but model access and effective reasoning budgets are not guaranteed by CLI help. Unsupported models/efforts remain visible failures; do not substitute. Record differences between native harnesses. The source copies are an experimental isolation measure, not a security boundary: native permissions differ and Bash can exceed prompt restrictions. Inspect execution evidence before claiming compliance.

## Fact-check and audit

After reviews finish, run `collect "$RUN"`. Read [adjudication.md](references/adjudication.md). Fact-check every submitted finding against the frozen source and relevant requirements. Trace callers, failure paths and reachable scenarios; use focused isolated checks when necessary. Reading tests is allowed; do not run the target's existing suites. Do not manufacture judgments just to complete the matrix.

Use `claims.json` without `claim-map.json` when giving claims to a fresh adjudicator. Fresh independent agents may be used when available and authorized; otherwise adjudicate in this session and record `labels_hidden: false`. Never describe adjudication as fully blind merely because exported metadata omits labels. Keep canonical issue IDs stable and deduplicate by actual root cause. Distinguish real defects, supported concerns, refuted claims and unresolved premises; record incorrect supporting assertions separately. No model gets credit for a concern merely because it sounds plausible.

Import verdicts with `adjudicate "$RUN" --file "$VERDICTS"`. The script validates exact evidence spans and preserves adjudication history. Inspect each attempt's `audit.json` tool calls and relevant process diagnostics for prohibited suites, mutations, remote access, delegation, retries or unclean helpers. Import the assessment with `audit "$RUN" --file "$AUDITS"`. Parser summaries are not automatic proof of compliance. Do not publish raw provider event streams or hidden reasoning in the report.

## Present the comparison

Run `report "$RUN"` to generate self-contained HTML; no JavaScript or external assets are required to display its content. Embedded JavaScript adds sorting for findings, duration, results and overlap columns; overlap rows can be sorted by discovery count, severity or issue ID. In viewers that disable scripts, all results remain visible in their original order. This command never calls a model. Review incomplete/flagged status, counts, timing, repeated-run ranges and overlap before drawing conclusions. Recommendations should account for confirmed yield, high-severity coverage, false claims, corrections and elapsed time. Discovery-union coverage is not true recall; a single run is not a stable ranking.

Open or link the HTML report and give the user the experiment directory for later resumption. Name failed or unresolved work plainly. All benchmark artifacts remain outside the reviewed repository unless the user asks to save them there afterward. Running this skill does not authorize modifying reviewed code, committing it, pushing it or publishing results.
