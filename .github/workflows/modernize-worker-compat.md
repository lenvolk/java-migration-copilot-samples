---
description: Worker - read-only analysis of source compatibility for the Asset Manager upgrade.

on:
  workflow_call:
    inputs:
      issue_number: { type: string, required: true }
      pr_number: { type: string, required: true }
      branch: { type: string, required: true }
      plan_path: { type: string, required: true }
  workflow_dispatch:
    inputs:
      issue_number: { description: "Modernization Request issue number", type: string, required: true }
      pr_number: { description: "Implementation pull request number", type: string, required: true }
      branch: { description: "Implementation branch", type: string, required: true }
      plan_path: { description: "Approved plan path", type: string, required: true }

permissions:
  contents: read
  issues: read
  pull-requests: read

engine:
  id: copilot
  concurrency:
    group: "gh-aw-copilot-modernize-compat-${{ inputs.issue_number }}"

concurrency:
  job-discriminator: ${{ inputs.issue_number }}

imports:
  - ../agents/modernize-compat-analyst.agent.md

skills:
  - .github/skills/java-upgrade-rules

checkout:
  ref: ${{ inputs.branch }}

tools:
  github:
    toolsets: [pull_requests]
  bash: ["cat", "ls", "grep", "find", "head", "wc", "sort", "uniq"]

safe-outputs:
  add-comment:
    target: "*"
    max: 1

timeout-minutes: 20
---

# Compatibility Analyst run

Run the Compatibility Analyst role for this task.

- Modernization Request issue: #${{ inputs.issue_number }}
- Implementation pull request: #${{ inputs.pr_number }} (branch `${{ inputs.branch }}`)
- Approved plan: `${{ inputs.plan_path }}`

Post your single comment on pull request #${{ inputs.pr_number }}.
