---
description: Stage 2 - writes the Asset Manager modernization plan from the approved assessment into the plan pull request, for human approval.

on:
  workflow_call:
    inputs:
      issue_number: { type: string, required: true }
      pr_number: { type: string, required: true }
      branch: { type: string, required: true }
      request_dir: { type: string, required: true }
      stage: { type: string, required: false, default: "modernize-planner" }
  workflow_dispatch:
    inputs:
      issue_number: { description: "Modernization Request issue number", type: string, required: true }
      pr_number: { description: "Plan pull request number", type: string, required: true }
      branch: { description: "Plan branch, for example modernize/plan-12", type: string, required: true }
      request_dir: { description: "Folder with assessment.md, for example docs/modernization/requests/12", type: string, required: true }
      stage: { description: "Stage name. Keeps artifact names unique per worker. Leave the default.", type: string, required: false, default: "modernize-planner" }

permissions:
  contents: read
  issues: read
  pull-requests: read

engine:
  id: copilot
  model: claude-sonnet-5.5
  concurrency:
    group: "gh-aw-copilot-modernize-planner-${{ inputs.issue_number }}"

concurrency:
  job-discriminator: ${{ inputs.issue_number }}

skills:
  - .github/skills/java-modernization
  - .github/skills/pr-description
  - .github/skills/pr
  - .github/skills/show-me

checkout:
  ref: ${{ inputs.branch }}

tools:
  github:
    toolsets: [issues, pull_requests]
  edit:
  bash: ["cat", "ls", "grep", "find", "head", "tail", "wc", "sed -n"]

safe-outputs:
  push-to-pull-request-branch:
    target: "*"
    required-title-prefix: "[modernization-plan] "
    if-no-changes: error
    fallback-as-pull-request: false
    max: 1
  update-pull-request:
    target: "*"
    title: false
    body: true
    max: 1

timeout-minutes: 20
---

# modernize-planner

Write a human-reviewable modernization plan for Asset Manager from the **approved** assessment. A human approved the assessment report at gate 1. A human approves this plan at gate 2 by merging the pull request. You never change application code.

## Context

- Modernization Request issue: #${{ inputs.issue_number }}
- Plan pull request: #${{ inputs.pr_number }} on branch `${{ inputs.branch }}`. It already contains, in `${{ inputs.request_dir }}/`:
  - `assessment.md`: the approved assessment report, with finding IDs and the reviewer decisions.
  - `findings.json`: the same findings as data. Every ID in it must appear in your plan.
  - `evidence/facts.json`, `evidence/rewrite.patch`, `evidence/osv.json`, `evidence/dependency-tree-*.txt`, `evidence/jdeps-*.txt`: tool output.
  - `cost-estimate.md`: estimated AI credits of the execution stage. The pipeline copies it into your plan.
- After the merge, `modernize-pipeline` runs `modernize-build-upgrader`, then `modernize-code-fixer`, then deterministic verification, then `modernize-conformance-reviewer` and `modernize-standards-reviewer` in parallel, and opens a draft Implementation pull request.

## Task

1. Read the request issue, `assessment.md`, `findings.json` and the evidence.
2. If `assessment.md` has a `## Reviewer notes at gate 1` section, those notes are binding. Answer every note in a `### Reviewer notes` subsection of `## Assessment Summary`: say how the plan follows it, or, if the evidence contradicts the note, say so with the evidence and keep the evidence-based choice. A deterministic check rejects the plan if the subsection is missing.
3. Create exactly one file: `${{ inputs.request_dir }}/plan.md`, in the format of the `java-modernization` skill.
4. Assign every finding ID from `findings.json` to exactly one execution step. Findings ranked `No change` go to the coverage table with step `none`.
5. Take every version and count from the files you read. Never invent one.
6. Leave the `## Cost Estimate` section with the single line `Filled in by the pipeline.` The pipeline replaces it with measured numbers.
7. Push the file to pull request #${{ inputs.pr_number }} with the push safe output. One commit: `docs: modernization plan for #${{ inputs.issue_number }}`.
8. Replace the pull request description with the `pr-description` skill, plan pull request variant (Summary, Evidence, Merge Danger), using `show-me` visuals. Link the request issue by number in the first sentence. Do not close the issue.

## Guardrails

- Do not edit any file outside `${{ inputs.request_dir }}/plan.md`.
- Do not edit `assessment.md`, `findings.json` or the evidence; they are the approved record.
- Do not include Azure service migration, containerization, deployment, CI/CD, observability, or production rollout in the execution steps.
- If `assessment.md` or `findings.json` is missing, push nothing and explain the problem.
