# Assessment report — report-20261016124235

**Sanitized review copy of the existing assessment, not a new assessment.**

- Original JSON: `C:\Temp\GHDemo\JavaModernization\java-migration-copilot-samples\.github\modernize\assessment\reports\report-20261016124235\report.json`
- Review copy: `C:\Temp\GHDemo\JavaModernization\java-migration-copilot-samples\.github\modernize\assessment\reports\report-20261016124235\assessment-report.md`
- Original report ID/name: `20261016124235` / `Report_20261016124235`.
- Original status: **cancelled**. Do not treat this as a completed or exhaustive
  assessment, or its reported security entries as newly verified vulnerabilities.
- Analysis started: `2026-10-16T16:42:35.619Z`.
- Analysis ended: `2026-10-17T23:33:58.461Z`.
- Review copy saved: `2026-10-19`.
- The original JSON was preserved unchanged. No assessment, vulnerability scan,
  build, test, migration or cloud operation was run to create this review copy.

## Reading this report

This export retains all **18 rule titles, 49 incident IDs and original evidence
locations**, plus all **21 security entries and their evidence file lists**.
Source/configuration values, code excerpts and free-text explanations are
intentionally omitted to avoid disclosing credentials. Consult the original
JSON only in an appropriately controlled local environment for those fields.
No secret value is reproduced here.

Locations below are repository-relative, displayed with Windows separators.
Line numbers are the original report's line numbers; a missing location or line
is explicitly marked. Repeated references are retained, not counted as separate
applications. Report severity labels are reproduced verbatim; they are not
reclassified into CVSS scores.

## Original summary

| Metric | Reported value |
|---|---:|
| Aggregate projects | 1 |
| Rule issues | 18 |
| Incidents | 49 |
| Total effort | 223 |
| Security entries | 21 |

The report's single aggregate project has path `.` and name
`java-migration-copilot-samples`; it is not a single application.
Reported project properties include JDK `8`, Maven, Spring/Spring Boot and
multiple languages including Java, C# and JavaScript. Do not apply that JDK
value uniformly to every repository sample.

## Migration findings

| Rule | Finding | Severity | Incidents | Effort |
|---|---|---|---:|---:|
| ant-build-tool-00001 | Ant build tool found | optional | 1 | 8 |
| azure-aws-config-region-02000 | AWS region configuration | mandatory | 4 | 2 |
| azure-aws-config-s3-03000 | AWS S3 usage found | mandatory | 2 | 8 |
| azure-database-microsoft-oracle-07000 | Oracle database found | potential | 2 | 8 |
| azure-database-microsoft-sql-03000 | Microsoft SQL database found | potential | 1 | 5 |
| azure-database-mysql-01000 | MySQL database found | potential | 2 | 5 |
| azure-database-postgresql-02000 | PostgreSQL database found | potential | 3 | 5 |
| azure-java-version-02000 | Java Version is not the latest LTS | optional | 5 | 8 |
| azure-message-queue-config-rabbitmq-01000 | RabbitMQ connection string, username or password found in configuration file | optional | 6 | 5 |
| azure-password-01000 | Password found in configuration file | potential | 5 | 3 |
| cra-hardcoded-credential-config-03000 | CRA: Hard-coded credentials in configuration files | mandatory | 2 | 5 |
| cra-hardcoded-credential-default-pwd-04000 | CRA: Default or well-known password detected | mandatory | 3 | 3 |
| localhost-00004 | Localhost Usage | optional | 5 | 3 |
| localhost-jdbc-00002 | Local JDBC Calls | mandatory | 2 | 5 |
| logging-0002 | Avoid File System Logging in Configuration | mandatory | 2 | 1 |
| mail-00000 | Java Mail API | potential | 1 | 5 |
| openliberty-database-00004 | Detect application-level data source references | mandatory | 1 | 5 |
| spring-boot-to-azure-restricted-config-01000 | Restricted configurations found | potential | 2 | 2 |

### Ant build tool — ant-build-tool-00001

- `de9ca8aa-c287-4fbf-9905-4c889b62af8e` —
  `jakarta-ee\student-web-app\build.xml` (line not provided).

### AWS region configuration — azure-aws-config-region-02000

- `bc37d285-36ee-47f3-b903-c2b6183b7477` —
  `asset-manager\web\src\main\resources\application.properties:6`.
- `d4a79de9-e2ba-4464-8b23-5f1d30e8ffe7` —
  `asset-manager\worker\src\main\java\com\microsoft\migration\assets\worker\config\AwsS3Config.java:19`.
- `83fa6fcc-b96f-4d19-b4c6-e6e0ee73fa12` —
  `asset-manager\web\src\main\java\com\microsoft\migration\assets\config\AwsS3Config.java:20`.
- `93021f33-6d3b-42ad-a974-656f7dc68073` —
  `asset-manager\worker\src\main\resources\application.properties:4`.

### AWS S3 — azure-aws-config-s3-03000

- `45308a4b-e455-4a3e-b3a5-e11042fbf6c7` —
  `asset-manager\web\src\main\resources\application.properties:7`.
- `28b573b8-4f66-404c-9979-c96a0637b793` —
  `asset-manager\worker\src\main\resources\application.properties:5`.

### Oracle — azure-database-microsoft-oracle-07000

- `acb278b0-709f-41b1-aab6-cd472b4d7312` —
  `todo-web-api-use-oracle-db\src\main\resources\application.yaml:3`.
- `5049e481-428b-4cb0-9457-747e45bbfa7a` —
  `todo-web-api-use-oracle-db\src\main\resources\application.yaml:6`.

### Microsoft SQL — azure-database-microsoft-sql-03000

- `c6069640-80eb-4b44-84a6-9a848ccd8fa0` —
  `mi-sql-public-demo\src\main\resources\application.properties:1`.

### MySQL — azure-database-mysql-01000

- `df97fdb8-cce4-4681-b9c9-0c860b0bb0f0` —
  `jakarta-ee\student-web-app\docker-compose.yml:29`.
- `29dd4fe3-fa01-41be-86ca-ce208563e69b` —
  location and line not provided.

### PostgreSQL — azure-database-postgresql-02000

- `1f99c6c1-8d5d-4313-afa0-4e764751a1af` —
  `asset-manager\web\src\main\resources\application.properties:20`.
- `9f920b56-01d4-4526-8fe5-84d83753a8d9` —
  `asset-manager\worker\src\main\resources\application.properties:17`.
- `5f2216ff-6919-4443-abbe-2bb5a837ffbf` —
  location and line not provided.

### Java version — azure-java-version-02000

- `5ed913ff-edd8-4107-9081-e909e4e50c9d` — `asset-manager\pom.xml:19`.
- `dc88cf5a-c03f-4005-9885-67530e6cf6f3` — `mi-sql-public-demo\pom.xml:15`.
- `74d6012b-01b4-4fe1-9784-5c5845343bdf` —
  `mi-sql-public-demo\pom.xml` (line not provided).
- `3d85db7c-7300-4f78-8e0d-e2214563b45f` — `rabbitmq-sender\pom.xml:17`.
- `3d695157-8432-43a2-b111-6460d9ed3286` —
  `todo-web-api-use-oracle-db\pom.xml:18`.

### RabbitMQ — azure-message-queue-config-rabbitmq-01000

- `63c885c0-aefb-4e66-8f73-28d694bc7ab7` —
  `asset-manager\web\src\main\resources\application.properties:14`.
- `ea0eb81f-ebfb-4b84-945b-cc416ab7385f` —
  `asset-manager\web\src\main\resources\application.properties:16`.
- `89231a75-078f-4a68-aef4-60e1de96ece9` —
  `asset-manager\web\src\main\resources\application.properties:17`.
- `ce487038-a52b-42c0-aaa2-2aba13084ecb` —
  `asset-manager\worker\src\main\resources\application.properties:11`.
- `65e6a3a3-f535-4f0a-8ddc-362ebff9841b` —
  `asset-manager\worker\src\main\resources\application.properties:13`.
- `d57994f3-7723-4b58-a2f8-03704c4d130c` —
  `asset-manager\worker\src\main\resources\application.properties:14`.

### Configuration passwords — azure-password-01000

- `65cbf580-fd32-4ae1-a555-d3007b75d594` —
  `todo-web-api-use-oracle-db\src\main\resources\application.yaml:5`.
- `bb9d6487-ad41-48c0-81fe-7ab699f9f642` —
  `asset-manager\worker\src\main\resources\application.properties:14`.
- `84989935-2ac3-40e9-864c-675cb8143145` —
  `asset-manager\worker\src\main\resources\application.properties:19`.
- `c3e9444b-2ffb-4a8e-8f23-f937fef2594d` —
  `asset-manager\web\src\main\resources\application.properties:17`.
- `7bc0256d-11c1-4355-bf38-09671dac4267` —
  `asset-manager\web\src\main\resources\application.properties:22`.

### Hardcoded credentials — cra-hardcoded-credential-config-03000

- `01e821bd-c2cd-409d-9f49-eda1f54f6979` —
  `asset-manager\web\src\main\resources\application.properties:5`.
- `8d007422-1582-437c-949e-df2ab607e127` —
  `asset-manager\worker\src\main\resources\application.properties:3`.

### Default passwords — cra-hardcoded-credential-default-pwd-04000

- `c35bc53a-5fc4-4ca0-bdaa-40aca20fe88d` —
  `jakarta-ee\student-web-app\liberty_config\server-docker.xml:27`.
- `37d27ed0-9952-4fb7-b9a3-967c70f2bf3e` —
  `asset-manager\worker\src\main\resources\application.properties:14`.
- `fff1d367-ea0c-4005-8c82-5a160239542c` —
  `asset-manager\web\src\main\resources\application.properties:17`.

### Localhost — localhost-00004

- `16285838-06de-4bd5-903b-11dacfcf6f19` —
  `todo-web-api-use-oracle-db\src\main\resources\application.yaml:3`.
- `ca23fa56-4d96-4e6a-b512-74c54af5798a` —
  `jakarta-ee\student-web-app\docker-compose.yml:18`.
- `dcf8ac08-d5db-4612-bee2-4b9d972a740d` —
  `jakarta-ee\student-web-app\liberty_config\server-docker.xml:23`.
- `a152fbfb-fb12-4b60-a23f-273c222f4c5c` —
  `asset-manager\web\src\main\resources\application.properties:14`.
- `b1dae0a0-9822-4f28-a899-3f347f73f2fb` —
  `asset-manager\worker\src\main\resources\application.properties:11`.

### Local JDBC — localhost-jdbc-00002

- `7fbd82aa-3e77-410b-83bd-becceed8873c` —
  `asset-manager\web\src\main\resources\application.properties:20`.
- `a9d3dde2-70a8-442e-ad34-bf699e9df60c` —
  `asset-manager\worker\src\main\resources\application.properties:17`.

### File logging — logging-0002

- `e2efb54a-75db-4051-8c4f-6227d36b1d6f` —
  `jakarta-ee\student-web-app\resources\log4j.properties:10`.
- `b325b9b5-a351-4a0c-82cd-5e3e22a5a056` —
  `jakarta-ee\student-web-app\resources\log4j.properties:11`.

### JavaMail — mail-00000

- `7011992e-555f-465f-9848-3ea3c3f78bac` —
  `jakarta-ee\student-web-app\liberty_config\server-docker.xml:22`.

### Open Liberty data source — openliberty-database-00004

- `d367c54b-c3ce-498f-b685-d7e2e81d3a58` —
  `jakarta-ee\student-web-app\WebContent\WEB-INF\web.xml:67`.

### Restricted configuration — spring-boot-to-azure-restricted-config-01000

- `5cc76e73-588b-4360-b83e-9922005da563` —
  `asset-manager\web\src\main\resources\application.properties:1`.
- `65c87642-02f2-4fc8-ac6e-649e30864432` —
  `asset-manager\worker\src\main\resources\application.properties:8`.

## Original security entries

These entries are reproduced from the existing report, **not verified by a new
security audit**. The report includes evidence in C#/JavaScript projects as well
as Java projects; retaining it here does not expand the Java modernization
plan's execution scope. No findings were silently removed because they fall
outside that plan.

### Code Quality

**CWE-477 — Use of Obsolete Function**  
Reported severity: `optional`.

- `asset-manager\web\src\main\java\com\microsoft\migration\assets\config\WebMvcConfig.java`

**CWE-606 — Unchecked Input for Loop Condition**  
Reported severity: `potential`.

- `ContosoUniversity\Scripts\notifications.js`
- `ContosoUniversity\Controllers\NotificationsController.cs`

**CWE-681 — Incorrect Conversion between Numeric Types**  
Reported severity: `potential`.

- `asset-manager\worker\src\main\java\com\microsoft\migration\assets\worker\service\AbstractFileProcessingService.java`

**CWE-682 — Incorrect Calculation**  
Reported severity: `potential`.

- `asset-manager\worker\src\main\java\com\microsoft\migration\assets\worker\service\AbstractFileProcessingService.java`

**CWE-772 — Missing Release of Resource after Effective Lifetime**  
Reported severity: `potential`.

- `asset-manager\web\src\main\java\com\microsoft\migration\assets\service\LocalFileStorageService.java`
- `Malshinon\CSV.cs`

**CWE-775 — Missing Release of File Descriptor or Handle after Effective Lifetime**  
Reported severity: `potential`.

- `asset-manager\web\src\main\java\com\microsoft\migration\assets\service\LocalFileStorageService.java`
- `Malshinon\CSV.cs`

**CWE-789 — Memory Allocation with Excessive Size Value**  
Reported severity: `potential`.

- `asset-manager\worker\src\main\java\com\microsoft\migration\assets\worker\service\AbstractFileProcessingService.java`
- `asset-manager\web\src\main\resources\application.properties`

**CWE-835 — Loop with Unreachable Exit Condition ('Infinite Loop')**  
Reported severity: `potential`.

- `ContosoUniversity\Scripts\notifications.js`

### Concurrency & Synchronization

**CWE-662 — Improper Synchronization**  
Reported severity: `potential`.

- `ContosoUniversity\Services\NotificationService.cs`
- `ContosoUniversity\Controllers\BaseController.cs`

**CWE-820 — Missing Synchronization**  
Reported severity: `potential`.

- `ContosoUniversity\Services\NotificationService.cs`
- `ContosoUniversity\Controllers\BaseController.cs`

### Credentials & Secrets

**CWE-259 — Use of Hard-coded Password**  
Reported severity: `optional`.

- `jakarta-ee\student-web-app\docker-compose.yml`
- `todo-web-api-use-oracle-db\src\main\resources\application.yaml`

**CWE-732 — Incorrect Permission Assignment for Critical Resource**  
Reported severity: `optional`.

- `ContosoUniversity\Services\NotificationService.cs`

**CWE-778 — Insufficient Logging**  
Reported severity: `potential`.

- `ContosoUniversity\Services\NotificationService.cs`
- `ContosoUniversity\Controllers\BaseController.cs`

**CWE-798 — Use of Hard-coded Credentials**  
Reported severity: `optional`.

- `jakarta-ee\student-web-app\docker-compose.yml`
- `todo-web-api-use-oracle-db\src\main\resources\application.yaml`

### File & Path Security

**CWE-22 — Improper Limitation of a Pathname to a Restricted Directory ('Path Traversal')**  
Reported severity: `optional`.

- `asset-manager\web\src\main\java\com\microsoft\migration\assets\controller\S3Controller.java`
- `asset-manager\web\src\main\java\com\microsoft\migration\assets\service\LocalFileStorageService.java`

**CWE-23 — Relative Path Traversal**  
Reported severity: `optional`.

- `asset-manager\worker\src\main\java\com\microsoft\migration\assets\worker\service\AbstractFileProcessingService.java`
- `asset-manager\worker\src\main\java\com\microsoft\migration\assets\worker\service\LocalFileProcessingService.java`

**CWE-36 — Absolute Path Traversal**  
Reported severity: `optional`.

- `asset-manager\web\src\main\java\com\microsoft\migration\assets\service\LocalFileStorageService.java`
- `asset-manager\web\src\main\java\com\microsoft\migration\assets\controller\S3Controller.java`

**CWE-434 — Unrestricted Upload of File with Dangerous Type**  
Reported severity: `mandatory`.

- `asset-manager\web\src\main\java\com\microsoft\migration\assets\controller\S3Controller.java`
- `asset-manager\web\src\main\java\com\microsoft\migration\assets\service\AwsS3Service.java`
- `asset-manager\web\src\main\java\com\microsoft\migration\assets\service\LocalFileStorageService.java`
- `asset-manager\web\src\main\resources\templates\upload.html`

### Injection Attacks

**CWE-89 — Improper Neutralization of Special Elements used in an SQL Command ('SQL Injection')**  
Reported severity: `mandatory`.

- `Malshinon\DAL\PeopleDAL.cs`
- `Malshinon\DBConnection.cs`
- `Malshinon\CSV.cs`
- `Malshinon\Program.cs`

**CWE-99 — Improper Control of Resource Identifiers ('Resource Injection')**  
Reported severity: `potential`.

- `ContosoUniversity\Controllers\CoursesController.cs`
- `ContosoUniversity\App_Start\FilterConfig.cs`

### CVE

**CVE-2025-59250 — JDBC Driver for SQL Server has improper input validation issue**  
Reported category: `CVE`. Reported severity: `mandatory`.

The source security entry has **no evidence file locations and no evidence
explanation**. Its presence in the report is preserved, but this review copy
does not establish a currently affected module/version, exploitability or fix
status. The original descriptive text is not reproduced. Validate applicability
and dependency versions during the separately requested future CVE work.

## Current-repository planning notes

These are previously performed read-only planning checks, not a new assessment:

- `mi-sql-public-demo` already requests managed-identity SQL authentication in
  `MainSQL.java`; the presence of SQL Server is not evidence that a new
  password-to-managed-identity migration is necessary.
- `rabbitmq-sender` already uses Service Bus; the AMQP incidents above reference
  Asset Manager, not that sample.
- Asset Manager AWS access/secret settings contain placeholders, not verified
  exposed credentials. The original hardcoded-credential entries remain above
  so the report history is not silently rewritten.
- The Student Web App compose localhost healthcheck is a local-dev container
  probe; it is not an application endpoint to migrate.
- “Latest LTS” does not select an approved Java target. Java/framework targets
  remain plan decisions, not conclusions supplied by this report export.
- The two DB incidents without locations establish no additional project scope.

## Preservation and validation

The review copy was checked against the original JSON for all migration rule
titles/IDs, all 49 incident IDs/locations, all 21 security IDs/titles/severity
labels and all security evidence file paths. The original report's status is
retained. No credential values or source excerpts are included.

The separate modernization plan is a blocked planning draft under
`.github\modernize\plan-report-20261016124235-20261019`.
Reviewing or saving this assessment report does not authorize execution.
