# Asset Manager Java Modernization Plan

## Request

Modernization Request #8: prepare Asset Manager for continued development on a supported baseline by upgrading Java 8 to Java 21 and Spring Boot 2.7 to Spring Boot 3.5, while preserving existing web and worker behavior.

## Run Parameters

```yaml
issue: 8
project: asset-manager
source: { java: 8, spring-boot: "2.7.x" }
target: { java: 21, spring-boot: "3.5.x" }
```

## Verified Baseline

- Java: `<java.version>8</java.version>` in `asset-manager/pom.xml`.
- Spring Boot: `spring-boot-starter-parent` 2.7.18 in `asset-manager/pom.xml`.
- Modules: `web` and `worker` (`asset-manager/web/pom.xml`, `asset-manager/worker/pom.xml`).
- Build tool: Maven with the Maven Wrapper (`asset-manager/mvnw`, Maven 3.9.9 in `.mvn/wrapper/maven-wrapper.properties`).
- Tests: one test class, `worker/src/test/java/com/microsoft/migration/assets/worker/service/S3FileProcessingServiceTest.java` (4 `@Test` methods). The `web` module has no `src/test` directory. Baseline results are not assumed green and are captured first by the pipeline.
- Namespace usage in Java sources: `javax.persistence` (5 imports), `javax.servlet` (2), `javax.annotation` (2), `javax.imageio` (16, part of the JDK).
- Files with `javax.persistence|annotation|servlet` imports: `web/.../model/ImageMetadata.java`, `web/.../config/WebMvcConfig.java`, `web/.../service/LocalFileStorageService.java`, `worker/.../model/ImageMetadata.java`, `worker/.../service/LocalFileProcessingService.java`, `worker/.../service/AbstractFileProcessingService.java`.

## In Scope

- Raise `java.version` to 21 and the Spring Boot parent to 3.5.x.
- Update dependency versions that Spring Boot 3.5 or Java 21 require, in `pom.xml` files only.
- Rename `javax.persistence`, `javax.annotation`, and `javax.servlet` imports to `jakarta.*`.
- Fix source and test compile errors and behavior changes caused by the upgrade.

## Out of Scope

- Azure service migration.
- Containerization.
- Deployment and CI/CD changes.
- Observability and production monitoring.
- Production rollout.
- New features or refactoring unrelated to the upgrade.

## Expected Impact

- Build files: `asset-manager/pom.xml` (Java version, parent), plus `web/pom.xml` and `worker/pom.xml` dependency versions if needed. Maven Wrapper change only if required.
- Namespaces: `javax.*` to `jakarta.*` in the six files above. `javax.imageio.*` stays unchanged.
- Configuration: review `application` properties for keys renamed or removed in Spring Boot 3.
- Tests: `S3FileProcessingServiceTest` may need updates for Mockito and JUnit versions bundled with Boot 3.5.
- Third-party dependencies: AWS SDK S3, PostgreSQL driver, Lombok, Jackson, and Hibernate (through Spring Data JPA) move to versions compatible with Boot 3.5 and Java 21.

## Execution Steps

1. `[modernize-compat-analyst]` and `[modernize-dependency-analyst]` run in parallel, read-only. They assess source compatibility and map dependency versions.
2. `[modernize-build-upgrader]` updates the Java version, Spring Boot parent, Maven Wrapper if needed, and dependency versions in `pom.xml` files only.
3. `[modernize-code-fixer]` changes source and tests until the build and tests pass on JDK 21.
4. `[modernize-conformance-reviewer]` plus deterministic verification compares the result with this plan.

## Validation

- Capture the baseline test result on JDK 8 first. Do not assume it is green.
- Build both modules on JDK 21.
- Tests are no worse than the baseline.
- No `javax.persistence`, `javax.annotation`, `javax.servlet`, or `javax.validation` imports remain.
- `javax.imageio` imports are unchanged.
- Versions match the target: Java 21 and Spring Boot 3.5.x.

## Risks and Recovery

- Hibernate 6 and Jakarta Persistence change query and mapping behavior. The code fixer reviews `ImageMetadata` entities and repositories.
- Lombok and the AWS SDK need versions that support Java 21. The dependency analyst flags them.
- Removed Spring Boot 2.7 properties may change runtime configuration silently. The compat analyst lists them.
- The baseline may already fail. The pipeline records it so the result is compared fairly.
- Recovery: each stage is independently re-runnable. Re-run the failed stage, or close the Implementation Pull Request and re-run the pipeline.

## Human Approval Checklist

- [ ] Scope is the runtime and framework upgrade of `asset-manager/` only.
- [ ] Targets are Java 21 and Spring Boot 3.5.x.
- [ ] Exclusions (Azure, containers, deployment, CI/CD, observability, rollout) are correct.
- [ ] Validation criteria are sufficient, including the baseline-first rule.

## Execution Handoff

Merging this plan pull request authorizes the `modernize-pipeline` workflow to start. A human still reviews the final Implementation Pull Request before anything reaches `main`.
