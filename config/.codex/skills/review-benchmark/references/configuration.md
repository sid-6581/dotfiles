# Configuration and execution

Requires Python 3.11+, Git, and authenticated native `codex` and/or `claude` executables for the selected providers. The process runner supports Linux, WSL and macOS. Provider flags are verified against installed CLI help before launch. No Python packages or API keys are installed by this skill.

The configuration is JSON. Example values below illustrate a matrix; they are not defaults or a claim of account access:

```json
{
  "scope": "diff",
  "base": "main",
  "head": "HEAD",
  "reviewers": [
    {"provider": "codex", "model": "gpt-6.1-terra", "effort": "high"},
    {"provider": "claude", "model": "claude-sonnet-5-5", "effort": "high"}
  ],
  "repetitions": 1,
  "concurrency": 1,
  "timeout_seconds": 7200,
  "seed": 1,
  "instructions": "Review correctness, robustness, performance and maintainability. Follow relevant repository conventions.",
  "exclude": [],
  "include_untracked": false
}
```

`diff` compares the exact base commit to head; it does not silently choose a merge base. Resolve a merge base explicitly when that is the intended scope. `tree` reviews the tracked head tree, without a baseline. `worktree` snapshots tracked working files, including staged and unstaged changes/deletions, against HEAD. It includes nonignored untracked files only when requested with `include_untracked: true`. Tracked executable bits and safe internal symlinks are preserved. Outside-root symlinks are rejected. Git blob contents are copied without checkout filters or export-ignore rules. Submodules need a separate benchmark or explicit exclusion; LFS blobs remain the stored pointer files, not downloaded objects. Exclusions use case-sensitive Python fnmatch patterns on repository-relative paths and affect both snapshots and the generated diff.

Scope includes unchanged source as context. Added/changed/removed paths are listed in `snapshot/scope.json`. The caller's dirty checkout is ignored for diff/tree and recorded as such. Preparation refuses an output directory inside the target repository and never overwrites an existing experiment directory.

## Commands

Use the current session's target repository, not the skill directory:

```sh
python "$SCRIPT" doctor --config "$CONFIG"
python "$SCRIPT" prepare --repo "$REPO" --config "$CONFIG"
python "$SCRIPT" run "$RUN"
python "$SCRIPT" status "$RUN"
python "$SCRIPT" resume "$RUN"
python "$SCRIPT" collect "$RUN"
python "$SCRIPT" adjudicate "$RUN" --file "$VERDICTS"
python "$SCRIPT" audit "$RUN" --file "$AUDITS"
python "$SCRIPT" report "$RUN"
```

`prepare --output /absolute/new/directory` overrides the default `$XDG_DATA_HOME/review-benchmark/runs/<id>` (or `~/.local/share/review-benchmark/runs/<id>`). `run` and `resume` are equivalent and skip all previously attempted cells unless `--retry-failed` is explicitly supplied. Successful completed reviews are never rerun within an experiment. Ctrl-C stops active process groups and retains their attempt records. A hard crash can leave running records and a lock: after the original owner stops, `unlock` removes a local stale lock; `--retry-failed` creates replacement attempts. The unknown actual duration of a hard-crashed process is not synthesized.

Recovery refuses to launch replacements while a saved review process group still exists. Inspect and stop surviving processes before retrying; an interrupted launch with no saved process identity requires manual inspection. Unknown crash durations are left unknown.

Each attempt saves its `workspace/`, `record.json`, `events.jsonl` and `stderr.txt`. An emitted final response is retained as `response.txt`; valid reviews also get normalized `review.json`. Extracted `audit.json` is retained even when final response validation fails. Invalid responses remain visible; they are not silently repaired by another model. Metadata uses monotonic wall timing and UTC timestamps. Queue wait and copying are excluded; native retries and termination cleanup are included. Provider usage is stored separately; token categories are not presumed comparable.

The report and collect stages use only the latest attempt per cell. Earlier attempts remain on disk for audit. Harness versions are pinned at the first launch: a changed executable/version on resume requires a new experiment. The resolved experiment, prompt hash and source manifest are saved; source/prompt mismatches stop further execution and report generation.

Do not put credentials, private provider transcripts, repository snapshots or experiment results in the dotfiles skill folder. The normal dotfiles installer installs the bundled skill files; experiment storage is independent.

## Portable report

`report.html` contains all CSS, optional sorting JavaScript, graphs, original reviews and quoted evidence in one file. Review sorting synchronizes the findings graph, timing graph, results table and overlap columns. Sort by confirmed defects, high-severity defects, concerns, refutations, unresolved claims, factual corrections, duration, defects per minute, accuracy, model, effort or run ID. Overlap rows sort by discovery count, severity or issue ID; both controls support ascending and descending order. Missing values stay last. No network request or separate JavaScript file is needed.

All content is rendered before scripts run. A preview that disables JavaScript still displays the full report; sorting controls appear only when scripts work. On narrow screens, graphs stack vertically and tables scroll horizontally within their sections.

## Skill installation

The skill is stored at `config/.codex/skills/review-benchmark` in dotfiles and uses the existing config-to-home installer mapping. Its `agents/openai.yaml` sets `allow_implicit_invocation: false`, so the intended entry point is `$review-benchmark` in a repository's Codex session. This follows the [official skill documentation](https://learn.chatgpt.com/docs/build-skills). A custom CODEX_HOME needs the same folder installed under that home's `skills/` directory.
