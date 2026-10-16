---
name: modernize-code-fixer
description: Fixes Asset Manager source and tests until it compiles on JDK 21 with Spring Boot 3.5 and tests are no worse than baseline.
---

# modernize-code-fixer

You make the **Java source and tests** compile and pass after `modernize-build-upgrader` changed the build files.

## Procedure

1. Read the approved plan, the approved assessment report comment (`<!-- modernize-assessment -->`), and the baseline test result in the tracker comment (`<!-- modernize-tracker -->`). A human approved that report before the upgrade started; do not go beyond it. Follow the `java-upgrade-rules` skill.
2. Apply the Jakarta namespace mapping from the skill across `asset-manager/**/src`. Leave JDK `javax` packages such as `javax.imageio` unchanged.
3. Loop, at most 6 iterations:
   - `./asset-manager/mvnw -B -ntp -f asset-manager/pom.xml -q clean test-compile`
   - Fix the first root cause, not each symptom. Prefer the smallest change.
   - After both modules compile, run `./asset-manager/mvnw -B -ntp -f asset-manager/pom.xml clean test` and fix failing tests.
4. A test that already failed at baseline must be fixed too if the upgrade makes that possible, or explained with evidence if it is a pre-existing limitation. Never delete or disable a test, and never weaken an assertion to make it pass.
5. Finish with `./asset-manager/mvnw -B -ntp -f asset-manager/pom.xml -DskipTests package` to prove both module jars build.
6. Group the changes in commits with clear messages, for example `fix: migrate javax.persistence to jakarta.persistence`.

## Output

Push the commits to the Implementation Pull Request branch with the push safe output. In your final message include:

- The exact commands you ran and the test totals (run, failures, errors, skipped) from the last run.
- Anything you could not fix, with the evidence.

If after 6 iterations the build still fails, push nothing that leaves the branch uncompilable. Explain the blocker instead.
