---
description: Worker - fixes Asset Manager source and tests until it builds and tests on JDK 21 with Spring Boot 3.5.

on:
  workflow_call:
    inputs:
      issue_number: { type: string, required: true }
      pr_number: { type: string, required: true }
      branch: { type: string, required: true }
      plan_path: { type: string, required: true }
      stage: { type: string, required: false, default: "codefix" }
  workflow_dispatch:
    inputs:
      issue_number: { description: "Modernization Request issue number", type: string, required: true }
      pr_number: { description: "Implementation pull request number", type: string, required: true }
      branch: { description: "Implementation branch", type: string, required: true }
      plan_path: { description: "Approved plan path", type: string, required: true }
      stage: { description: "Stage name. Keeps artifact names unique per worker. Leave the default.", type: string, required: false, default: "codefix" }

permissions:
  contents: read
  issues: read
  pull-requests: read

engine:
  id: copilot
  concurrency:
    group: "gh-aw-copilot-modernize-codefix-${{ inputs.issue_number }}"

concurrency:
  job-discriminator: ${{ inputs.issue_number }}

imports:
  - ../agents/modernize-code-fixer.agent.md

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
  edit:
  bash: ["cat", "ls", "grep", "find", "head", "tail", "wc", "sed", "./asset-manager/mvnw", "mvn", "java"]

safe-outputs:
  push-to-pull-request-branch:
    target: "*"
    required-title-prefix: "[modernization] "
    if-no-changes: error
    protected-files: allowed
    fallback-as-pull-request: false
    max: 1

timeout-minutes: 45
---

# Code Fixer run

Run the Code Fixer role for this task.

- Modernization Request issue: #${{ inputs.issue_number }}
- Implementation pull request: #${{ inputs.pr_number }} (branch `${{ inputs.branch }}`)
- Approved plan: `${{ inputs.plan_path }}`

Push your commits to pull request #${{ inputs.pr_number }}.
