---
description: Stage 2 - plans the Asset Manager Java modernization and opens a plan pull request for human approval.

on:
  slash_command:
    name: modernize-plan
    events: [issues, issue_comment]

permissions:
  contents: read
  issues: read
  copilot-requests: none

engine:
  id: copilot
  model: claude-sonnet-4.6

skills:
  - .github/skills/java-modernization
  - .github/skills/pr-description

safe-outputs:
  create-pull-request:
    title-prefix: "[modernization-plan] "
    draft: false
    auto-close-issue: false
    max: 1
---

# modernize-planner

Create a human-reviewable modernization plan for the Asset Manager application. This workflow plans the work. It never changes application code.

## Context

- The triggering issue is the Modernization Request.
- The application is in `asset-manager/`.
- The source baseline is Java 8 and Spring Boot 2.7.
- The approved target for this demo is Java 21 and Spring Boot 3.5.
- After a human merges the plan pull request, the `modernize-pipeline` workflow executes the plan with dedicated agents.

## Task

1. Read the triggering issue and inspect the Asset Manager Maven project.
2. Verify the current Java and Spring Boot versions from `asset-manager/pom.xml`.
3. Create exactly one file:

   `docs/modernization/requests/<issue-number>-asset-manager-java-upgrade.md`

4. Follow the plan format and scope rules in the `java-modernization` skill, including the `Run Parameters` block.
5. Request one pull request containing only that plan file.

## Pull request

- Title: `Plan Asset Manager Java modernization for #<issue-number>`
- Body: write it with the `pr-description` skill, plan pull request variant. It has three sections: Summary, Evidence, Merge Danger.
  - Summary: the flow diagram, the version diff, and the execution tree. Take every version and count from the files you read.
  - Evidence: the verified baseline with file paths, and the checks the Implementation pull request must pass.
  - Merge Danger: merging is the explicit human approval that starts the `modernize-pipeline` workflow. Application code is unchanged by this pull request.
  - Link the Modernization Request by number in the first sentence. Do not close it: it stays open until the Implementation pull request merges.
  - Follow the writing rules in the skill.

## Guardrails

- Do not edit files under `asset-manager/`.
- Do not run the modernization, modify dependencies, or generate application code.
- Do not include Azure service migration, containerization, deployment, observability, or production rollout.
- Do not create more than one plan file or more than one pull request.
- If the repository does not contain `asset-manager/` or its baseline cannot be verified, call `noop` and explain the mismatch.
