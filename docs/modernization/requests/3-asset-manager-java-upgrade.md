# Asset Manager Java Modernization Plan

## Request

Issue #3, "Modernize Asset Manager to Java 21 and Spring Boot 3.5". Business outcome: keep Asset Manager on a supported Java and Spring Boot baseline while preserving the existing web and worker behavior.

## Run Parameters

```yaml
issue: 3
project: asset-manager
source: { java: 8, spring-boot: "2.7.x" }
target: { java: 21, spring-boot: "3.5.x" }
```

## Verified Baseline

- Java: `java.version` is `8` in `asset-manager/pom.xml`.
- Spring Boot: parent `spring-boot-starter-parent` is `2.7.18` in `asset-manager/pom.xml`.
- Modules: `web` (`asset-manager/web/pom.xml`) and `worker` (`asset-manager/worker/pom.xml`).
- Build tool: Maven, via the Maven Wrapper (`asset-manager/.mvn/wrapper/maven-wrapper.properties`, Maven 3.9.9).
- Dependencies of note: AWS SDK v2 `s3` 2.25.13 (property `aws-sdk.version` in both modules), `spring-boot-starter-data-jpa`, `spring-boot-starter-amqp`, `postgresql`, `lombok`, `spring-boot-starter-thymeleaf` (web only), `spring-boot-devtools` (web only), `jackson-databind` (worker only).
- Tests: one test class, `asset-manager/worker/src/test/java/com/microsoft/migration/assets/worker/service/S3FileProcessingServiceTest.java`. The `web` module has no tests.
- `javax.*` imports that must change (5 files):
  - `web/.../model/ImageMetadata.java` (`javax.persistence`)
  - `web/.../config/WebMvcConfig.java` (`javax.servlet.http`)
  - `web/.../service/LocalFileStorageService.java` (`javax.annotation`)
  - `worker/.../model/ImageMetadata.java` (`javax.persistence`)
  - `worker/.../service/LocalFileProcessingService.java` (`javax.annotation`)
- `javax.imageio.*` in `worker/.../service/AbstractFileProcessingService.java` ships with the JDK and stays unchanged.

## In Scope

- Raise the Java version from 8 to 21.
- Raise the Spring Boot parent from 2.7.18 to 3.5.x.
- Update the Maven Wrapper and third-party dependency versions only where Spring Boot 3.5 or JDK 21 requires it.
- Rename `javax.persistence`, `javax.servlet` and `javax.annotation` imports to `jakarta.*`.
- Fix compile errors, configuration property changes and test failures caused by the upgrade.

## Out of Scope

- Azure service migration.
- Containerization.
- Deployment and CI/CD changes.
- Observability and production monitoring.
- Production rollout.
- New features or behavior changes.

## Expected Impact

- Build files: `asset-manager/pom.xml`, `web/pom.xml`, `worker/pom.xml`, and possibly `.mvn/wrapper/maven-wrapper.properties`.
- Namespaces: 5 files move from `javax.*` to `jakarta.*`. `javax.imageio.*` is untouched.
- Configuration: review `application` properties for keys renamed or removed in Spring Boot 3.x.
- Tests: `S3FileProcessingServiceTest` may need updates for newer Mockito and JUnit versions.
- Third-party dependencies: check AWS SDK, Lombok, PostgreSQL driver, Thymeleaf and AMQP compatibility with Spring Boot 3.5 and JDK 21. Hibernate 6 behavior changes may affect the two `ImageMetadata` entities.

## Execution Steps

1. `[compat-analyst]` and `[dependency-analyst]` (in parallel, read-only): list source compatibility issues and map dependencies to versions compatible with Spring Boot 3.5 and Java 21.
2. `[build-upgrader]`: update the Java version, Spring Boot parent, Maven Wrapper and dependency versions in `pom.xml` files only.
3. `[code-fixer]`: change source and tests until both modules build on JDK 21 and tests are no worse than baseline.
4. `[conformance-reviewer]` plus deterministic verification: compare the result with this plan and write the Implementation pull request summary.

## Validation

- Capture the baseline test result first, on JDK 8. Do not assume it is green.
- Build both modules (`web`, `worker`) on JDK 21 with `asset-manager/mvnw`.
- Tests are no worse than the baseline result.
- No remaining `javax.persistence`, `javax.annotation`, `javax.servlet` or `javax.validation` imports.
- `java.version` is 21 and the Spring Boot parent is 3.5.x.

## Risks and Recovery

- Hibernate 6 and Spring Data JPA changes may alter entity mapping behavior. Recovery: re-run `[code-fixer]` with the failing output.
- A dependency may lack a compatible version. Recovery: re-run `[build-upgrader]` with the analyst findings, or record it as a blocker.
- The baseline tests may already fail. Recovery: record the baseline and require no regression.
- Each stage is independently re-runnable.

## Human Approval Checklist

- [ ] Source baseline (Java 8, Spring Boot 2.7.18) is correct.
- [ ] Targets (Java 21, Spring Boot 3.5.x) are correct.
- [ ] Out of scope list is acceptable.
- [ ] Validation criteria are sufficient.

## Execution Handoff

Merging this plan pull request authorizes the `Modernize Asset Manager - Pipeline` workflow to start. A human still reviews the final Implementation Pull Request before it reaches `main`.
