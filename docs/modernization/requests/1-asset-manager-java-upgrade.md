# Asset Manager Java Modernization Plan

## Request

Issue #1, "Modernize Asset Manager to Java 21 and Spring Boot 3.5". Business outcome: prepare Asset Manager for continued development on a supported Java and Spring Boot baseline while preserving existing web and worker behavior.

## Run Parameters

```yaml
issue: 1
project: asset-manager
source: { java: 8, spring-boot: "2.7.x" }
target: { java: 21, spring-boot: "3.5.x" }
```

## Verified Baseline

- Java: 8 (`asset-manager/pom.xml`, property `java.version`).
- Spring Boot: 2.7.18 (`spring-boot-starter-parent` in `asset-manager/pom.xml`).
- Build tool: Maven, multi-module parent POM with Maven Wrapper 3.9.9 (`asset-manager/mvnw`, `asset-manager/.mvn/wrapper/maven-wrapper.properties`).
- Modules: `web` (Thymeleaf, Web, AMQP, JPA, PostgreSQL, AWS SDK S3 2.25.13, Lombok) and `worker` (AMQP, JPA, PostgreSQL, AWS SDK S3 2.25.13, Jackson, Lombok).
- Tests: one test class found, `worker/src/test/java/com/microsoft/migration/assets/worker/service/S3FileProcessingServiceTest.java`. `web` has no tests.
- `javax.*` usage found in: `web/.../model/ImageMetadata.java`, `web/.../config/WebMvcConfig.java`, `web/.../service/LocalFileStorageService.java`, `worker/.../model/ImageMetadata.java`, `worker/.../service/LocalFileProcessingService.java`.

## In Scope

- Upgrade Java 8 to Java 21 for both modules.
- Upgrade Spring Boot 2.7.18 to 3.5.x.
- Compatibility changes the upgrade requires: `javax.*` to `jakarta.*`, dependency version alignment, configuration property changes, and test fixes.

## Out of Scope

- Azure service migration.
- Containerization.
- Deployment and CI/CD.
- Observability and monitoring.
- Production rollout.
- New features or behavior changes.

## Expected Impact

- Build files: `asset-manager/pom.xml`, `web/pom.xml`, `worker/pom.xml` (Java version, Spring Boot parent, plugin and dependency versions); Maven Wrapper only if required by the toolchain.
- Namespaces: `javax.persistence`, `javax.annotation`, `javax.servlet`, `javax.validation` become `jakarta.*`. `javax.imageio.*` is part of the JDK and must not be renamed.
- Configuration: review `application*.properties/yml` for properties renamed or removed in Spring Boot 3.x (JPA/Hibernate 6, AMQP).
- Tests: `S3FileProcessingServiceTest` may need updates for newer Mockito/JUnit versions.
- Dependencies: check PostgreSQL driver, Lombok, AWS SDK S3, Jackson, and Thymeleaf for Boot 3.5 and JDK 21 compatibility; remove an explicit version where Boot manages it.

## Execution Steps

1. `[compat-analyst]` and `[dependency-analyst]` (parallel, read-only): assess source compatibility issues and map third-party dependencies to versions that work with Spring Boot 3.5 and Java 21.
2. `[build-upgrader]`: update Java version, Spring Boot parent, Maven Wrapper if needed, and dependency versions in the `pom.xml` files only.
3. `[code-fixer]`: fix source and tests until both modules compile on JDK 21 and tests are no worse than baseline.
4. `[conformance-reviewer]` plus deterministic verification: compare the result against this plan and write the pull request summary.

## Validation

- Capture the baseline test result first on the source version. Never assume baseline tests are green.
- Build both `web` and `worker` with JDK 21.
- Tests are no worse than baseline.
- No remaining `javax.persistence|annotation|servlet|validation` imports.
- Versions match the target: Java 21, Spring Boot 3.5.x.

## Risks and Recovery

- Hibernate 6 and JPA 3 behavior changes: limited to the `ImageMetadata` entities; review mapping annotations and queries.
- Third-party library incompatibility (AWS SDK, Lombok, PostgreSQL driver): resolved by the dependency analysis in Step 1.
- Only one test exists, so coverage of regressions is thin: the reviewer flags behavior changes.
- Recovery: each stage is independently re-runnable; re-run the failed stage after fixing its inputs. Nothing merges without human review.

## Human Approval Checklist

- [ ] Scope is limited to the runtime and framework upgrade of `asset-manager/`.
- [ ] Targets are Java 21 and Spring Boot 3.5.x.
- [ ] Exclusions (Azure, containers, deployment, CI/CD, observability, rollout) are acceptable.
- [ ] Validation criteria are sufficient.

## Execution Handoff

Merging this plan pull request is the explicit human approval that authorizes the `Modernize Asset Manager - Pipeline` workflow to start. A human still reviews the final Implementation Pull Request before anything reaches the main branch.
