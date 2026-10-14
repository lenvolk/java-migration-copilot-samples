#!/usr/bin/env python3
"""Create or update the single 'tracker' comment on the modernization pull request.

The comment is the shared status board of the pipeline: one row per stage.
Agents read it for the baseline test result. Plain jobs write to it.

Usage:
  modernize_tracker.py --pr 12 --stage "Baseline tests" --status "done" --detail "1 run, 1 failed"
Requires GH_TOKEN and GITHUB_REPOSITORY in the environment.
"""
import argparse
import json
import os
import subprocess
import sys

MARKER = "<!-- modernize-tracker -->"
STAGES = [
    "Plan approved",
    "Baseline tests",
    "Compatibility analysis",
    "Dependency analysis",
    "Build upgrade",
    "Code fixes",
    "Build and test verification",
    "Plan-conformance review",
    "Human review",
]
ICONS = {"pending": "⏳", "running": "🔄", "done": "✅", "failed": "❌", "attention": "⚠️"}


def gh(*args, stdin=None):
    result = subprocess.run(["gh", *args], input=stdin, capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(f"gh {' '.join(args)} failed: {result.stderr.strip()}")
    return result.stdout


def parse_rows(body):
    rows = {}
    for line in body.splitlines():
        if line.startswith("|") and not line.startswith("| Stage") and not line.startswith("|---"):
            cells = [c.strip() for c in line.strip("|").split("|")]
            if len(cells) >= 3:
                rows[cells[0]] = (cells[1], cells[2])
    return rows


def render(rows, run_url):
    lines = [
        MARKER,
        "## Modernization pipeline status",
        "",
        f"Pipeline run: {run_url}",
        "",
        "| Stage | Status | Detail |",
        "|---|---|---|",
    ]
    for stage in STAGES:
        status, detail = rows.get(stage, (f"{ICONS['pending']} pending", ""))
        lines.append(f"| {stage} | {status} | {detail} |")
    lines += ["", "_Updated automatically. Re-run a failed stage from the Actions run; the branch keeps all earlier work._"]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--pr", required=True)
    parser.add_argument("--stage")
    parser.add_argument("--status", choices=ICONS.keys())
    parser.add_argument("--detail", default="")
    parser.add_argument("--run-url", default="")
    args = parser.parse_args()

    repo = os.environ["GITHUB_REPOSITORY"]
    out = gh("api", f"repos/{repo}/issues/{args.pr}/comments", "--paginate", "--jq", ".[] | {id, body}")
    comments = [json.loads(line) for line in out.splitlines() if line.strip()]
    existing = next((c for c in comments if MARKER in c["body"]), None)

    rows = parse_rows(existing["body"]) if existing else {}
    run_url = args.run_url
    if existing and not run_url:
        for line in existing["body"].splitlines():
            if line.startswith("Pipeline run:"):
                run_url = line.split(":", 1)[1].strip()
    if args.stage:
        if args.stage not in STAGES:
            sys.exit(f"Unknown stage: {args.stage}")
        rows[args.stage] = (f"{ICONS[args.status]} {args.status}", args.detail.replace("|", "/").replace("\n", " "))

    body = render(rows, run_url)
    if existing:
        gh("api", "-X", "PATCH", f"repos/{repo}/issues/comments/{existing['id']}", "-F", "body=@-", stdin=body)
    else:
        gh("api", "-X", "POST", f"repos/{repo}/issues/{args.pr}/comments", "-F", "body=@-", stdin=body)


if __name__ == "__main__":
    main()
