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

engine: copilot

skills:
  - .github/skills/java-modernization

safe-outputs:
  create-pull-request:
    title-prefix: "[modernization-plan] "
    draft: false
    max: 1
---

# Asset Manager Modernization Planner

Create a human-reviewable modernization plan for the Asset Manager application. This workflow plans the work. It never changes application code.

## Context

- The triggering issue is the Modernization Request.
- The application is in `asset-manager/`.
- The source baseline is Java 8 and Spring Boot 2.7.
- The approved target for this demo is Java 21 and Spring Boot 3.5.
- After a human merges the plan pull request, the `Modernize Asset Manager - Pipeline` workflow executes the plan with dedicated agents.

## Task

1. Read the triggering issue and inspect the Asset Manager Maven project.
2. Verify the current Java and Spring Boot versions from `asset-manager/pom.xml`.
3. Create exactly one file:

   `docs/modernization/requests/<issue-number>-asset-manager-java-upgrade.md`

4. Follow the plan format and scope rules in the `java-modernization` skill, including the `Run Parameters` block.
5. Request one pull request containing only that plan file.

## Pull request

- Title: `Plan Asset Manager Java modernization for #<issue-number>`
- Body:
  - Link to the triggering issue.
  - State the verified source and target versions.
  - Explain that merging this pull request is the explicit human approval that starts the modernization pipeline.
  - State that application code is unchanged by this pull request.

## Guardrails

- Do not edit files under `asset-manager/`.
- Do not run the modernization, modify dependencies, or generate application code.
- Do not include Azure service migration, containerization, deployment, observability, or production rollout.
- Do not create more than one plan file or more than one pull request.
- If the repository does not contain `asset-manager/` or its baseline cannot be verified, call `noop` and explain the mismatch.
