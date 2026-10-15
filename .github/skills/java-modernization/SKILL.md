---
name: java-modernization
description: Produce a reviewable Java and Spring Boot modernization plan for the Asset Manager demo. Planning only.
---

# Asset Manager Java Modernization Planning

Use this skill only to **plan** the Asset Manager runtime and framework upgrade. A human approves the plan by merging it. The modernization pipeline in `.github/workflows/modernize-pipeline.yml` then executes the approved plan with dedicated agents.

The plan follows the same phases as GitHub Copilot app modernization: assess, plan, execute in small steps, validate. This repository mimics that pattern with its own agents. It does not run the product.

## Source of truth

- Application: `asset-manager/` (modules `web` and `worker`, Maven Wrapper in `asset-manager/mvnw`).
- Baseline: read `asset-manager/pom.xml`. Expect Java 8 and Spring Boot 2.7.x.
- Demo target: Java 21 and Spring Boot 3.5.x.

Repository evidence takes precedence over assumptions. If the baseline differs, record the difference as a blocker instead of inventing an upgrade path.

## Plan format

Create one Markdown file with exactly these sections, in this order:

1. `# Asset Manager Java Modernization Plan`
2. `## Request` - issue reference and business outcome.
3. `## Run Parameters` - one fenced `yaml` block with these keys (the pipeline agents read it):

   ```yaml
   issue: <issue-number>
   project: asset-manager
   source: { java: 8, spring-boot: "2.7.x" }
   target: { java: 21, spring-boot: "3.5.x" }
   ```

4. `## Verified Baseline` - Java version, Spring Boot version, modules, build tool, tests found. Cite file paths.
5. `## In Scope` - runtime and framework upgrade plus the compatibility changes it requires.
6. `## Out of Scope` - Azure service migration, containerization, deployment, CI/CD, observability, production rollout.
7. `## Expected Impact` - build files, `javax.*` to `jakarta.*` namespaces, configuration, tests, third-party dependencies.
8. `## Execution Steps` - ordered steps, each tagged with the agent that performs it:
   - Step 1 `[modernize-compat-analyst]` and `[modernize-dependency-analyst]` (parallel, read-only): assess source and dependencies.
   - Step 2 `[modernize-build-upgrader]`: Java version, Spring Boot parent, Maven Wrapper, dependency versions in `pom.xml` files only.
   - Step 3 `[modernize-code-fixer]`: source and test changes until build and tests pass.
   - Step 4 `[modernize-conformance-reviewer]` plus deterministic verification: compare the result with this plan.
9. `## Validation` - baseline test result captured first, JDK 21 build of both modules, tests no worse than baseline, no remaining `javax.persistence|annotation|servlet|validation` imports, versions match the target. Never assume the baseline tests are green.
10. `## Risks and Recovery` - identified risks, and how to recover (re-run the failed stage; each stage is independently re-runnable).
11. `## Human Approval Checklist` - verify scope, targets, exclusions, and validation before merging.
12. `## Execution Handoff` - state that merging this plan pull request authorizes the pipeline to start, and that a human still reviews the final Implementation Pull Request.

Keep the plan reviewable in five minutes.

## Boundaries

- Planning only. Never edit `asset-manager/`.
- Do not include hand-written code in the plan.
- `javax.imageio.*` is part of the JDK. Never plan to rename it.
- Do not expand into Azure migration, containers, or deployment.
