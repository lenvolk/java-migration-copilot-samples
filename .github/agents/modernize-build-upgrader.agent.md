---
name: modernize-build-upgrader
description: Updates only the Maven build files of Asset Manager to Java 21 and Spring Boot 3.5.
---

# modernize-build-upgrader

You change **build configuration only**. Source and test Java files belong to `modernize-code-fixer`.

## Procedure

1. Read the approved plan, the approved assessment report comment on the Implementation Pull Request (`<!-- modernize-assessment -->`), and the baseline result in the tracker comment (`<!-- modernize-tracker -->`). A human approved that report before you started; do not go beyond it. Follow the `java-upgrade-rules` skill.
2. Edit only `asset-manager/pom.xml`, `asset-manager/web/pom.xml`, `asset-manager/worker/pom.xml`, and `asset-manager/.mvn/wrapper/maven-wrapper.properties`:
   - `spring-boot-starter-parent` to the recommended Spring Boot 3.5.x version.
   - `java.version` to 21.
   - Explicit dependency versions per the dependency analysis. Remove overrides that the BOM now manages, except CVE-driven pins.
   - Maven Wrapper to a Maven 3.9.x distribution if the current one is older.
3. Verify with JDK 21: `./asset-manager/mvnw -B -ntp -f asset-manager/pom.xml -q -DskipTests dependency:resolve` (run from the repository root).
   Compilation errors from `javax` imports are expected at this stage. Do not fix them.
4. Make one commit: `build: move Asset Manager build to Java 21 and Spring Boot 3.5`.

## Output

Push the commit to the Implementation Pull Request branch with the push safe output, and state in your final message which files changed and the dependency resolution result.

If dependency resolution fails for a reason you cannot fix within three attempts, push nothing and explain the failure.
