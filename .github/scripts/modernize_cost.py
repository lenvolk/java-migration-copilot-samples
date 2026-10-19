#!/usr/bin/env python3
"""Estimate and report the Copilot AI credits that the modernization agents use.

estimate: project the cost of a stage before a human approves it. The token profile per role
          was measured on a real pipeline run; prices come from the GitHub Copilot pricing page.
actual:   sum the credits that gh-aw recorded for the agents of a finished run.

Usage:
  modernize_cost.py estimate --stages assessment,plan,execution [--format md|json]
  modernize_cost.py actual --artifacts <dir with *-info and *-usage artifacts> [--format md|json]

1 AI credit = 0.01 USD. Estimates are a range, not a quote: tokens vary by model, by run, and by
how many build and fix iterations the code fixer needs.
"""
import argparse
import json
import pathlib
import re
import sys

PRICING_SOURCE = "https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing"
PRICING_DATE = "2026-10-19"

# USD per 1 million tokens: input, cached input, cache write (None = the model has no cache-write price), output.
PRICES = {
    "gpt-5-mini": (0.25, 0.025, None, 2.00),
    "gpt-5.3-codex": (1.75, 0.175, None, 14.00),
    "gpt-5.4": (2.50, 0.25, None, 15.00),
    "gpt-5.4-mini": (0.75, 0.075, None, 4.50),
    "gpt-5.4-nano": (0.20, 0.02, None, 1.25),
    "gpt-5.5": (5.00, 0.50, None, 30.00),
    "gpt-5.6-luna": (0.20, 0.02, 0.25, 1.20),
    "gpt-5.6-terra": (2.00, 0.20, 2.50, 12.00),
    "gpt-5.6-sol": (4.00, 0.40, 5.00, 20.00),
    "gpt-6-luna": (0.10, 0.01, 0.125, 0.50),
    "gpt-6-sol": (2.00, 0.20, 2.50, 10.00),
    "gpt-6.1-sol": (2.00, 0.10, 2.50, 10.00),
    "claude-haiku-4.5": (1.00, 0.10, 1.25, 5.00),
    "claude-haiku-5.5": (0.10, 0.01, 0.125, 0.50),
    "claude-sonnet-4": (3.00, 0.30, 3.75, 15.00),
    "claude-sonnet-4.6": (3.00, 0.30, 3.75, 15.00),
    "claude-sonnet-5": (2.00, 0.20, 2.50, 10.00),
    "claude-sonnet-5.5": (2.00, 0.10, 2.50, 10.00),
    "claude-opus-5.5": (4.00, 0.20, 5.00, 20.00),
}

# Tokens per agent run, measured on pipeline run 38800093610 and planner run 38796634967 (2026-10-15).
# requests, input, output, cache read, cache write. `scale` adjusts for the more detailed prompts and
# outputs of this version (evidence files to read, structured findings, traceability tables).
PROFILES = {
    "modernize-compat-analyst": {"tokens": (6, 5400, 2400, 150000, 29000), "scale": 1.6},
    "modernize-dependency-analyst": {"tokens": (6, 5400, 2400, 150000, 29000), "scale": 1.6},
    "modernize-planner": {"tokens": (6, 5223, 4579, 212487, 48722), "scale": 1.5},
    "modernize-build-upgrader": {"tokens": (9, 6160, 2188, 274549, 37746), "scale": 1.1},
    "modernize-code-fixer": {"tokens": (14, 6239, 4827, 481290, 26872), "scale": 1.2},
    "modernize-conformance-reviewer": {"tokens": (6, 5554, 4752, 195598, 45907), "scale": 1.3},
    "modernize-standards-reviewer": {"tokens": (6, 5554, 4752, 195598, 45907), "scale": 1.2},
}
# Every gh-aw agent run is followed by a threat-detection job that reviews its output.
DETECTION = {"model": "claude-haiku-5.5", "tokens": (2, 17500, 450, 22000, 30000)}
# Low and high multipliers around the point estimate. The code fixer loops, so its range is wider.
BAND = {"default": (0.6, 2.0), "modernize-code-fixer": (0.6, 3.0)}

STAGES = {
    "assessment": ["modernize-compat-analyst", "modernize-dependency-analyst"],
    "plan": ["modernize-planner"],
    "execution": ["modernize-build-upgrader", "modernize-code-fixer", "modernize-conformance-reviewer", "modernize-standards-reviewer"],
}
STAGE_TITLES = {"assessment": "Assessment", "plan": "Plan", "execution": "Execution"}


def workflow_model(name, workflows):
    path = pathlib.Path(workflows) / f"{name}.md"
    if not path.exists():
        return None
    front = path.read_text(encoding="utf-8").split("---")[1]
    match = re.search(r"(?m)^engine:\s*\n(?:\s+.*\n)*?\s+model:\s*([\w.\-]+)", front)
    return match.group(1) if match else None


def credits(model, inp, out, cache_read, cache_write):
    price = PRICES.get(model)
    if not price:
        return None
    p_in, p_cached, p_write, p_out = price
    # Models without a cache-write price bill those tokens as normal input.
    write_price = p_write if p_write is not None else p_in
    usd = (inp * p_in + cache_read * p_cached + cache_write * write_price + out * p_out) / 1_000_000
    return usd * 100


def estimate_rows(stages, workflows):
    rows = []
    for stage in stages:
        for name in STAGES[stage]:
            model = workflow_model(name, workflows) or "unknown"
            req, inp, out, cr, cw = PROFILES[name]["tokens"]
            s = PROFILES[name]["scale"]
            tokens = [round(x * s) for x in (inp, out, cr, cw)]
            point = credits(model, *tokens)
            low, high = BAND.get(name, BAND["default"])
            d_req, *d_tokens = DETECTION["tokens"]
            detect = credits(DETECTION["model"], *d_tokens)
            rows.append({
                "stage": stage, "agent": name, "model": model, "requests": round(req * s),
                "input": tokens[0], "output": tokens[1], "cache_read": tokens[2], "cache_write": tokens[3],
                "credits": point, "low": point * low if point is not None else None, "high": point * high if point is not None else None,
                "detection_credits": detect,
            })
    return rows


def fmt_tokens(value):
    return f"{value / 1000:.1f}K" if value < 1_000_000 else f"{value / 1_000_000:.2f}M"


def fmt_credits(value):
    return "n/a" if value is None else f"{value:.1f}"


def fmt_usd(value):
    return "n/a" if value is None else f"${value / 100:.2f}"


def estimate_markdown(rows):
    lines = ["| Stage | Agent | Model | Requests | Input | Output | Cache read | Cache write | AI credits (range) | USD (range) |",
             "|---|---|---|---:|---:|---:|---:|---:|---|---|"]
    for r in rows:
        lines.append(f"| {STAGE_TITLES[r['stage']]} | `{r['agent']}` | `{r['model']}` | ~{r['requests']} | {fmt_tokens(r['input'])} | {fmt_tokens(r['output'])} | "
                     f"{fmt_tokens(r['cache_read'])} | {fmt_tokens(r['cache_write'])} | {fmt_credits(r['credits'])} ({fmt_credits(r['low'])} to {fmt_credits(r['high'])}) | "
                     f"{fmt_usd(r['credits'])} ({fmt_usd(r['low'])} to {fmt_usd(r['high'])}) |")
    detect = sum(r["detection_credits"] for r in rows)
    lines.append(f"| All | threat detection after each agent ({len(rows)} runs) | `{DETECTION['model']}` | ~{2 * len(rows)} | | | | | {fmt_credits(detect)} | {fmt_usd(detect)} |")
    known = [r for r in rows if r["credits"] is not None]
    total = sum(r["credits"] for r in known) + detect
    low = sum(r["low"] for r in known) + detect
    high = sum(r["high"] for r in known) + detect
    lines.append(f"| **Total** | | | | | | | | **{fmt_credits(total)} ({fmt_credits(low)} to {fmt_credits(high)})** | **{fmt_usd(total)} ({fmt_usd(low)} to {fmt_usd(high)})** |")
    unknown = [r["agent"] for r in rows if r["credits"] is None]
    lines += ["", f"Estimate from token counts measured on a real run of this pipeline, scaled for this version's prompts. "
              f"Prices: [GitHub Copilot models and pricing]({PRICING_SOURCE}), read {PRICING_DATE}. 1 AI credit = $0.01. "
              "Credits count against the Copilot plan of the `COPILOT_GITHUB_TOKEN` owner; usage beyond the plan's included credits is billed. "
              "Deterministic jobs (tests, Maven, OpenRewrite, OSV) use GitHub Actions minutes and no AI credits."]
    if unknown:
        lines.append(f"No price on record for the model of: {', '.join(unknown)}. Add it to `PRICES` in `.github/scripts/modernize_cost.py`.")
    return "\n".join(lines) + "\n", total


def read_usage(artifacts):
    """Map each gh-aw artifact prefix to its workflow name and recorded token usage."""
    root = pathlib.Path(artifacts)
    names = {}
    for info in root.glob("*-info/aw_info.json"):
        names[info.parent.name[: -len("-info")]] = json.loads(info.read_text())["workflow_name"]
    rows = []
    for usage in sorted(root.glob("*-usage")):
        prefix = usage.name[: -len("-usage")]
        for kind in ("agent", "detection"):
            path = usage / kind / "token_usage.jsonl"
            if not path.exists():
                continue
            totals = {"requests": 0, "input": 0, "output": 0, "cache_read": 0, "cache_write": 0, "credits": 0.0, "models": set()}
            for line in path.read_text().splitlines():
                record = json.loads(line) if line.strip() else {}
                if record.get("event") != "token_usage":
                    continue
                totals["requests"] += 1
                totals["input"] += record.get("input_tokens", 0)
                totals["output"] += record.get("output_tokens", 0)
                totals["cache_read"] += record.get("cache_read_tokens", 0)
                totals["cache_write"] += record.get("cache_write_tokens", 0)
                totals["credits"] += record.get("ai_credits_this_response", 0) or 0
                totals["models"].add(record.get("model", "unknown"))
            totals["agent"] = names.get(prefix, prefix)
            totals["kind"] = kind
            totals["models"] = ", ".join(sorted(totals["models"]))
            rows.append(totals)
    return rows


def actual_markdown(rows):
    agents = sorted([r for r in rows if r["kind"] == "agent"], key=lambda r: r["agent"])
    detection = [r for r in rows if r["kind"] == "detection"]
    lines = ["| Agent | Model used | Requests | Input | Output | Cache read | Cache write | AI credits | USD |", "|---|---|---:|---:|---:|---:|---:|---:|---:|"]
    for r in agents:
        lines.append(f"| `{r['agent']}` | `{r['models']}` | {r['requests']} | {fmt_tokens(r['input'])} | {fmt_tokens(r['output'])} | {fmt_tokens(r['cache_read'])} | "
                     f"{fmt_tokens(r['cache_write'])} | {r['credits']:.1f} | {fmt_usd(r['credits'])} |")
    if detection:
        d = sum(r["credits"] for r in detection)
        lines.append(f"| threat detection ({len(detection)} runs) | `{', '.join(sorted({r['models'] for r in detection}))}` | {sum(r['requests'] for r in detection)} | | | | | {d:.1f} | {fmt_usd(d)} |")
    total = sum(r["credits"] for r in rows)
    lines.append(f"| **Total** | | | | | | | **{total:.1f}** | **{fmt_usd(total)}** |")
    lines += ["", "Recorded by gh-aw for every model request (`token_usage.jsonl` in the `*-usage` artifacts of this run). 1 AI credit = $0.01."]
    return "\n".join(lines) + "\n", total


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    e = sub.add_parser("estimate")
    e.add_argument("--stages", default="assessment,plan,execution")
    e.add_argument("--workflows", default=".github/workflows")
    e.add_argument("--format", choices=["md", "json"], default="md")
    a = sub.add_parser("actual")
    a.add_argument("--artifacts", required=True)
    a.add_argument("--format", choices=["md", "json"], default="md")
    args = parser.parse_args()

    if args.command == "estimate":
        rows = estimate_rows([s.strip() for s in args.stages.split(",") if s.strip()], args.workflows)
        if args.format == "json":
            print(json.dumps(rows, indent=2))
        else:
            print(estimate_markdown(rows)[0], end="")
    else:
        rows = read_usage(args.artifacts)
        if args.format == "json":
            print(json.dumps(rows, indent=2))
        elif rows:
            print(actual_markdown(rows)[0], end="")
        else:
            print("No gh-aw usage artifacts found in this run.")


if __name__ == "__main__":
    sys.exit(main())
