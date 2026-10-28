"""Native CLI adapters. Requested identifiers are never silently substituted."""

import json
import shutil
import subprocess

from common import validate_review, write_json

FLAGS = {
    "codex": (
        "--ignore-user-config",
        "--ignore-rules",
        "--ephemeral",
        "--sandbox",
        "--output-last-message",
        "--json",
    ),
    "claude": (
        "--safe-mode",
        "--strict-mcp-config",
        "--permission-mode",
        "--no-session-persistence",
        "--output-format",
        "--effort",
    ),
}


def preflight(reviewers):
    versions = {}
    for provider in sorted({r["provider"] for r in reviewers}):
        executable = shutil.which(provider)
        if not executable:
            raise ValueError(
                f"Missing {provider} executable; install and authenticate it before running",
            )
        command = (
            [executable, "exec", "--help"]
            if provider == "codex"
            else [executable, "--help"]
        )
        help_result = subprocess.run(
            command, capture_output=True, text=True, check=True,
        )
        missing = [flag for flag in FLAGS[provider] if flag not in help_result.stdout]
        if missing:
            raise ValueError(f"{provider} lacks required options: {missing}")
        result = subprocess.run(
            [executable, "--version"], capture_output=True, text=True, check=True,
        )
        versions[provider] = {
            "executable": executable,
            "version": result.stdout.strip(),
            "preflight_stderr": help_result.stderr + result.stderr,
        }
    for reviewer in reviewers:
        if reviewer["effort"] not in (
            "minimal",
            "low",
            "medium",
            "high",
            "xhigh",
            "max",
        ):
            raise ValueError(
                f"Unknown effort: {reviewer['effort']}; no automatic mapping",
            )
        if reviewer["provider"] == "claude" and reviewer["effort"] == "minimal":
            raise ValueError("Claude does not advertise minimal effort")
    return versions


def command(reviewer, directory, executable):
    model, effort = reviewer["model"], reviewer["effort"]
    if reviewer["provider"] == "codex":
        return [
            executable,
            "exec",
            "--ignore-user-config",
            "--ignore-rules",
            "--ephemeral",
            "--skip-git-repo-check",
            "--sandbox",
            "read-only",
            "--model",
            model,
            "-c",
            f'model_reasoning_effort="{effort}"',
            "-c",
            "project_doc_max_bytes=0",
            "--disable",
            "multi_agent",
            "--json",
            "--output-last-message",
            str(directory / "response.txt"),
            "-",
        ]
    return [
        executable,
        "--print",
        "--model",
        model,
        "--effort",
        effort,
        "--safe-mode",
        "--strict-mcp-config",
        "--tools",
        "Read,Glob,Grep,Bash",
        "--allowedTools",
        "Read,Glob,Grep,Bash",
        "--permission-mode",
        "dontAsk",
        "--no-session-persistence",
        "--output-format",
        "stream-json",
        "--verbose",
    ]


def parse(provider, directory):
    final = None
    malformed = 0
    tool_calls = []
    usage = {}
    observed_models = set()
    with (directory / "events.jsonl").open(
        encoding="utf-8", errors="replace",
    ) as stream:
        for line in stream:
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                malformed += 1
                continue
            if not isinstance(event, dict):
                malformed += 1
                continue
            message = event.get("message", {})
            if not isinstance(message, dict):
                message = {}
            for value in (event.get("model"), message.get("model")):
                if isinstance(value, str):
                    observed_models.add(value)
            item = event.get("item", {})
            if (
                isinstance(item, dict)
                and event.get("type") == "item.completed"
                and item.get("type") == "command_execution"
            ):
                tool_calls.append({"tool": "shell", "command": item.get("command", "")})
            for block in (
                message.get("content", [])
                if isinstance(message.get("content"), list)
                else []
            ):
                if isinstance(block, dict) and block.get("type") == "tool_use":
                    tool_calls.append(
                        {"tool": block.get("name"), "input": block.get("input")},
                    )
            if provider == "codex" and event.get("type") == "turn.completed":
                final = event
                usage = event.get("usage", {})
            elif provider == "claude" and event.get("type") == "result":
                final = event
                usage = event.get("usage", {})
    audit = {
        "usage": usage,
        "observed_model_ids": sorted(observed_models),
        "malformed_event_lines": malformed,
        "tool_calls": tool_calls,
        "provider_api_ms": (final or {}).get("duration_api_ms"),
        "provider_cost_usd": (final or {}).get("total_cost_usd"),
        "protocol_audit": "pending",
    }
    write_json(directory / "audit.json", audit)
    if final is None or final.get("is_error"):
        raise ValueError("CLI did not emit a successful final result event")
    if provider == "claude":
        content = final.get("structured_output", final.get("result", ""))
        response = (
            json.dumps(content, ensure_ascii=False)
            if isinstance(content, dict)
            else content
        )
        (directory / "response.txt").write_text(response, encoding="utf-8")
    else:
        response = (directory / "response.txt").read_text(encoding="utf-8")
    normalized = response.strip()
    if normalized.startswith("```") and normalized.endswith("```"):
        normalized = normalized.split("\n", 1)[1].rsplit("```", 1)[0].strip()
    review = validate_review(json.loads(normalized))
    return review, audit
