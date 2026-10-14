---
description: Worker - read-only analysis of third-party dependencies and build tooling for the Asset Manager upgrade.

on:
  workflow_call:
    inputs:
      issue_number: { type: string, required: true }
      pr_number: { type: string, required: true }
      branch: { type: string, required: true }
      plan_path: { type: string, required: true }
      stage: { type: string, required: false, default: "deps" }
  workflow_dispatch:
    inputs:
      issue_number: { description: "Modernization Request issue number", type: string, required: true }
      pr_number: { description: "Implementation pull request number", type: string, required: true }
      branch: { description: "Implementation branch", type: string, required: true }
      plan_path: { description: "Approved plan path", type: string, required: true }
      stage: { description: "Stage name. Keeps artifact names unique per worker. Leave the default.", type: string, required: false, default: "deps" }

permissions:
  contents: read
  issues: read
  pull-requests: read

engine:
  id: copilot
  concurrency:
    group: "gh-aw-copilot-modernize-deps-${{ inputs.issue_number }}"

concurrency:
  job-discriminator: ${{ inputs.issue_number }}

imports:
  - ../agents/modernize-dependency-analyst.agent.md

skills:
  - .github/skills/java-upgrade-rules

checkout:
  ref: ${{ inputs.branch }}

runtimes:
  java:
    version: "21"

network:
  allowed: [defaults, java]

tools:
  github:
    toolsets: [pull_requests]
  bash: ["cat", "ls", "grep", "find", "head", "wc", "sort", "uniq", "curl", "./asset-manager/mvnw", "mvn", "java"]

safe-outputs:
  add-comment:
    target: "*"
    max: 1

timeout-minutes: 20
---

# Dependency Analyst run

Run the Dependency Analyst role for this task.

- Modernization Request issue: #${{ inputs.issue_number }}
- Implementation pull request: #${{ inputs.pr_number }} (branch `${{ inputs.branch }}`)
- Approved plan: `${{ inputs.plan_path }}`

Post your single comment on pull request #${{ inputs.pr_number }}.
