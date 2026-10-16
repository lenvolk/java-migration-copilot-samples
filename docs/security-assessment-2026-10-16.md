# Security assessment - 2026-10-16

## Review summary

**CWE review complete: 59/59 rules assessed; 20 FOUND, 39 NOT_FOUND, 0 PENDING.**

**Dependency CVE check completed with limited coverage: 3 unique version-resolved Maven coordinates checked; 1 HIGH advisory match.** Another 28 direct dependency declarations could not be version-resolved under the plan's static-fallback constraints. This is not a clean bill of health for dependencies.

After grouping overlapping CWE matches, this review records **12 security findings**: 0 critical, 5 high, 6 medium and 1 low. Three additional low-priority observations cover startup concurrency, deprecated APIs and thumbnail arithmetic; they are not counted as independently exploitable security vulnerabilities.

Application source, build files and dependency versions were not changed. No remediation, commit, push, live exploitation or production access was performed.

- Baseline commit: `606837f4d69f5ef8fcb13fc6de19e3c5816b1c84`.
- Assessment date/time zone: October 16, 2026, America/New_York.
- Governing plan: [security-assessment-plan.md](../.github/modernize/assessment/engines/security/security-assessment-plan.md).
- Raw dependency results: [cve_assessment_result.json](../.github/modernize/assessment/engines/security/cve_assessment_result.json).
- Rule-by-rule decisions: [CWE checklists](../.github/modernize/assessment/engines/security/cweChecklist/).

## Scope and execution

The source inventory covers first-party applications in [asset-manager](../asset-manager/), [jakarta-ee](../jakarta-ee/), [rabbitmq-sender](../rabbitmq-sender/), [todo-web-api-use-oracle-db](../todo-web-api-use-oracle-db/), [mi-sql-public-demo](../mi-sql-public-demo/), [ContosoUniversity](../ContosoUniversity/) and [Malshinon](../Malshinon/). It includes Java and C# source, first-party notification JavaScript, views/templates and relevant application configuration. The inventory contained 45 Java files, including a test, and 42 C# files.

The method was application-wide, category-specific source/sink searches followed by inspection of relevant control flow and input-to-sink paths. It was not a formal proof or an exhaustive manual reading of every source line. Vendored browser libraries, generated output, build tooling, operational scripts and CI workflows were not audited as application source. Dependency CVE coverage is Maven-only; NuGet packages, vendored JavaScript, Ant-managed JARs, build plugins, external parent/BOM artifacts and transitive dependencies were not CVE-assessed.

Execution followed the supplied plan's initialization and simultaneous launch of one CVE batch plus six CWE batches. The named `modernize-java-assessment` agent was unavailable, so general-purpose agents were used. Each category invoked `appmod-cwe-rules-assessment`; that tool supplies rules and review instructions, not precomputed source findings. The initial category agents stopped at that response and could not be resumed in this runtime. The user then explicitly authorized completing the assessment directly and saving it for review. The reviewer performed the source assessment and updated all six checklists under that authorization.

The CVE batch used `appmod-cve-assessment`. Neither `appmod-run-assessment-action` nor `appmod-run-assessment-report` was called. No web-based version resolution or independent web CVE lookup was used.

`FOUND` means that the specified rule matched inspected code. It does not imply that every match is an independently exploitable vulnerability. `NOT_FOUND` means that no supported instance was identified within this static review's scope and method, not that exploitation is impossible. Except for the CVE tool's HIGH rating, the severity and confidence values below are reviewer assessments, not tool-provided CVSS scores or statistical probabilities.

## Security findings

| ID | Severity | Source | Lines | Finding | Confidence |
|---|---|---|---|---|---|
| F01 | HIGH | [Maven dependency](../mi-sql-public-demo/pom.xml) | 19-22 | CVE-2025-59250: affected SQL Server JDBC driver version | 9/10 |
| F02 | HIGH | [PeopleDAL.cs](../Malshinon/DAL/PeopleDAL.cs) | 43-47 | Unparameterized SQL receives console/CSV input | 9/10 |
| F03 | HIGH | [LocalFileStorageService.java](../asset-manager/web/src/main/java/com/microsoft/migration/assets/service/LocalFileStorageService.java) | 89-95 | Absolute upload filenames escape the storage root in the dev profile | 9/10 |
| F04 | MEDIUM | [LocalFileProcessingService.java](../asset-manager/worker/src/main/java/com/microsoft/migration/assets/worker/service/LocalFileProcessingService.java) | 38-49 | Queue-controlled relative paths escape local worker storage | 9/10 |
| F05 | HIGH | [CoursesController.cs](../ContosoUniversity/Controllers/CoursesController.cs) | 130, 170-175 | Client-selected image path controls deletion of application files | 9/10 |
| F06 | HIGH | [NotificationService.cs](../ContosoUniversity/Services/NotificationService.cs) | 20-23 | Everyone receives full control of the notification queue | 10/10 |
| F07 | MEDIUM | [Compose configuration](../jakarta-ee/student-web-app/docker-compose.yml), [Oracle configuration](../todo-web-api-use-oracle-db/src/main/resources/application.yaml) | 6-11, 30-31; 4-5 | Fixed demo database passwords/accounts are usable defaults | 9/10 |
| F08 | MEDIUM | [notifications.js](../ContosoUniversity/Scripts/notifications.js) | 113-130 | Six visible notifications cause a synchronous infinite loop | 10/10 |
| F09 | MEDIUM | [AbstractFileProcessingService.java](../asset-manager/worker/src/main/java/com/microsoft/migration/assets/worker/service/AbstractFileProcessingService.java) | 99-105 | Image decoding allocates memory before a pixel/dimension limit | 8/10 |
| F10 | MEDIUM | [LocalFileStorageService.java](../asset-manager/web/src/main/java/com/microsoft/migration/assets/service/LocalFileStorageService.java), [CSV.cs](../Malshinon/CSV.cs) | 95; 25-30 | Opened input streams/readers lack deterministic release | 9/10 |
| F11 | MEDIUM | [S3Controller.java](../asset-manager/web/src/main/java/com/microsoft/migration/assets/controller/S3Controller.java), [AwsS3Service.java](../asset-manager/web/src/main/java/com/microsoft/migration/assets/service/AwsS3Service.java) | 41-49; 68-76 | Uploads lack server-side content/type validation | 8/10 |
| F12 | LOW | [NotificationService.cs](../ContosoUniversity/Services/NotificationService.cs), [BaseController.cs](../ContosoUniversity/Controllers/BaseController.cs) | 63-86; 28 | Notification failures lack durable, attributable audit diagnostics | 9/10 |

### F01 - SQL Server JDBC advisory match

- **Evidence:** The declared coordinate is `com.microsoft.sqlserver:mssql-jdbc:10.2.0.jre11`. The required CVE tool returned [CVE-2025-59250 / GHSA-m494-w24q-6f7w](https://github.com/advisories/GHSA-m494-w24q-6f7w), titled "JDBC Driver for SQL Server has improper input validation issue", with HIGH severity.
- **Impact/prerequisites:** This establishes an affected-version advisory match. The advisory's attack conditions and exploitability in this application's managed-identity connection path were not dynamically verified.
- **Review action:** Upgrade to an appropriate supported, patched driver release and validate compatibility. The tool lists `10.2.4.jre11` as a fix in the existing branch, plus patched newer branches.
- **Location limitation:** The CVE tool persisted an empty `evidence.files` array despite receiving declaration locations. Its raw output is preserved unchanged; the source location above was verified against the declaring build file.

### F02 - SQL injection from console or imported CSV

- **CWE:** 89.
- **Evidence:** [PeopleDAL.GetIdBySecretCode](../Malshinon/DAL/PeopleDAL.cs) embeds `secretCode` into a quoted SQL string. [DBConnection.Command/Send/Execute](../Malshinon/DBConnection.cs), lines 22-32 and 53-60, executes the supplied command text without parameters. Inputs come from [Program.cs](../Malshinon/Program.cs) or [CSV.ImportCsv](../Malshinon/CSV.cs), lines 42-68. The person and report insertion paths also build SQL with string interpolation.
- **Impact/prerequisites:** An operator or party supplying an imported CSV can change query semantics under the configured database identity. This is a console/import attack surface, not a demonstrated unauthenticated HTTP endpoint.
- **Review action:** Bind parameters for every data value, keep identifier construction separate, and use a least-privilege database identity. No query was executed against a database during this review.

### F03 - Absolute-path upload outside local storage

- **CWEs:** 22, 36; one root cause.
- **Evidence:** [LocalFileStorageService.uploadObject](../asset-manager/web/src/main/java/com/microsoft/migration/assets/service/LocalFileStorageService.java), lines 89-95, rejects filenames containing `..`, but does not reject absolute paths or check containment after resolution. `Files.copy` uses `REPLACE_EXISTING`. The [upload controller](../asset-manager/web/src/main/java/com/microsoft/migration/assets/controller/S3Controller.java), lines 41-49, passes the multipart file through.
- **Impact/prerequisites:** With the `dev` profile active and the upload endpoint reachable, a crafted server-native absolute filename can select a process-writable destination whose parent exists. Default behavior of a particular browser's file picker is not a server-side validation boundary. RCE was not established.
- **Verification:** Windows Java `Path.resolve` returned a destination outside a hypothetical storage root for an absolute operand. No real file was written and no live multipart request was submitted.
- **Review action:** Generate a server-side basename, reject rooted/absolute and separator-bearing names, normalize and verify containment, and account for symbolic links and overwrite policy.

### F04 - Relative traversal from worker queue messages

- **CWE:** 23.
- **Evidence:** [AbstractFileProcessingService.processImage](../asset-manager/worker/src/main/java/com/microsoft/migration/assets/worker/service/AbstractFileProcessingService.java) passes a message key into local file processing. [LocalFileProcessingService](../asset-manager/worker/src/main/java/com/microsoft/migration/assets/worker/service/LocalFileProcessingService.java), lines 38-49, resolves original and thumbnail paths without containment checks.
- **Impact/prerequisites:** A publisher able to submit a local-storage message can select paths outside the configured root under the worker's filesystem permissions. Thumbnail writes also depend on successful decoding of the selected original image. This requires queue-publishing access and the `dev` profile; public HTTP traversal or arbitrary secret exfiltration was not demonstrated.
- **Review action:** Validate message keys independently at the worker boundary, enforce normalized containment for reads and writes, and constrain queue publishers.

### F05 - Client-controlled application-file deletion

- **CWE:** 99; also a filesystem-boundary issue.
- **Evidence:** [CoursesController.Edit](../ContosoUniversity/Controllers/CoursesController.cs), line 130, binds `TeachingMaterialImagePath` from the request. During a replacement upload, lines 170-175 map and delete that client-selected path. The old path is not loaded from trusted persisted state and is not confined to the teaching-material upload directory. The create/edit paths can also persist a supplied path for later deletion.
- **Impact/prerequisites:** An otherwise valid form submission, including an anti-forgery token, can select another application-relative file for deletion if the application identity can delete it. The [global authorization filter](../ContosoUniversity/App_Start/FilterConfig.cs) is disabled; the inspected course controller has no authorization attribute. Hosting-level access controls were not assessed.
- **Review action:** Remove filesystem paths from client-bindable fields, load trusted metadata by course ID, authorize the operation, and enforce a strict upload-root boundary before deletion. No deletion was attempted.

### F06 - Overly broad notification-queue ACL

- **CWE:** 732.
- **Evidence:** [NotificationService](../ContosoUniversity/Services/NotificationService.cs), line 23, explicitly grants `Everyone` `MessageQueueAccessRights.FullControl` when creating the queue.
- **Impact/prerequisites:** Principals admitted by that ACL can inject/remove notifications, alter queue permissions or disrupt the queue. Actual access also depends on Windows/MSMQ and network configuration; anonymous Internet access is not claimed.
- **Review action:** Provision the queue with explicit producer, consumer and administrative identities and only the rights each requires.

### F07 - Fixed database credentials in demo configuration

- **CWEs:** 259, 798; one configuration weakness.
- **Evidence:** The student application's [Compose configuration](../jakarta-ee/student-web-app/docker-compose.yml), lines 6-9 and 30-31, contains literal database passwords/account configuration and publishes the database port at line 11. The Oracle application's [configuration](../todo-web-api-use-oracle-db/src/main/resources/application.yaml), lines 4-5, supplies a privileged account with a literal password.
- **Impact/prerequisites:** Deploying these defaults unchanged where another party can reach the database makes access predictable. These are demo/default values, not verified leaked live credentials. No authentication attempt was made; password values are intentionally excluded from this report and checklist evidence.
- **Review action:** Require externally supplied secrets, isolate database ports, use least-privilege application accounts, and rotate any defaults actually deployed.

### F08 - Notification count causes browser denial of service

- **CWEs:** 606, 835; one reproduced root cause.
- **Evidence:** [limitNotifications](../ContosoUniversity/Scripts/notifications.js), lines 124-130, repeatedly calls `closeNotification` while the DOM has more than five notifications. Lines 113-121 remove an element only in a timer callback. The synchronous loop never yields for that timer to run. [GetNotifications](../ContosoUniversity/Controllers/NotificationsController.cs), lines 20-27, can return ten events.
- **Impact/prerequisites:** Six events displayed before earlier notifications are removed hang the page's main JavaScript thread. Normal application activity or injected queue events can supply the count; no script injection is needed. The [shared layout](../ContosoUniversity/Views/Shared/_Layout.cshtml) loads this script.
- **Verification:** The unchanged script was run in an isolated Node VM with a minimal DOM/timer stub. Five notifications returned normally. Six reached the VM's 100 ms timeout, safely confirming that deferred removal cannot make progress. No browser or live service was hung.
- **Review action:** Remove or detach excess elements synchronously before another iteration, or iterate a finite snapshot without waiting for asynchronous DOM changes.

### F09 - Decoded image size is unbounded

- **CWE:** 789.
- **Evidence:** [generateThumbnail](../asset-manager/worker/src/main/java/com/microsoft/migration/assets/worker/service/AbstractFileProcessingService.java), line 99, calls `ImageIO.read` before any pixel-count or dimension check. The [web configuration](../asset-manager/web/src/main/resources/application.properties) caps compressed request bytes, not decoded image memory.
- **Impact/prerequisites:** An uploader whose image reaches the worker can submit a compact image with very large decoded dimensions, potentially exhausting worker heap before downscaling. Resource exhaustion is inferred from the missing boundary; an oversized allocation was deliberately not attempted.
- **Review action:** Inspect image metadata before decoding, bound width/height/total pixels and concurrent decode memory, and isolate image processing.

### F10 - Input streams and file handles are not deterministically closed

- **CWEs:** 772, 775; overlapping resource-lifetime rules.
- **Evidence:** [LocalFileStorageService.uploadObject](../asset-manager/web/src/main/java/com/microsoft/migration/assets/service/LocalFileStorageService.java), line 95, obtains an input stream without a closing scope; `Files.copy` does not close the supplied stream. File-backed multipart implementations can hold a descriptor. [CSV.ImportCsv](../Malshinon/CSV.cs), line 25, opens a `StreamReader` without `using`, `Dispose` or `Close`, including on the empty-file return.
- **Impact/prerequisites:** Repeated affected operations can retain handles or file locks until runtime/container cleanup. A remote handle-exhaustion threshold was not measured.
- **Review action:** Close owned Java streams with try-with-resources and C# readers with `using`; cover early returns and exceptions.

### F11 - Uploaded content is not validated on the server

- **CWE:** 434.
- **Evidence:** The [controller](../asset-manager/web/src/main/java/com/microsoft/migration/assets/controller/S3Controller.java) checks emptiness only. Both storage implementations save uploaded bytes before thumbnail decoding. [AwsS3Service](../asset-manager/web/src/main/java/com/microsoft/migration/assets/service/AwsS3Service.java), lines 68-76, also accepts the client-supplied content type. The [upload form](../asset-manager/web/src/main/resources/templates/upload.html) `accept` attribute is only a browser hint.
- **Impact/prerequisites:** Non-image or active content can remain in storage even if thumbnail processing rejects it. Active-content delivery depends on bucket/download policy; the application's download endpoint uses an octet-stream response. Server-side execution, application-origin stored XSS and public bucket access were not established.
- **Review action:** Apply a server-side content/signature/extension policy before storage, generate safe names, and explicitly configure safe download headers and bucket access.

### F12 - Notification/audit failures are not durably attributable

- **CWE:** 778.
- **Evidence:** [NotificationService](../ContosoUniversity/Services/NotificationService.cs), lines 63-86, records failures only with `Debug.WriteLine`; a receive failure becomes the same `null` result as an empty queue. [BaseController](../ContosoUniversity/Controllers/BaseController.cs), line 28, attributes changes to a fixed system identity.
- **Impact/prerequisites:** Queue tampering or failed audit delivery can be difficult to distinguish from normal inactivity. Debug calls can be omitted in release builds; an actual production logging configuration was not inspected.
- **Review action:** Use durable structured diagnostics, separate empty-queue results from operational failures, and record an authenticated or otherwise meaningful actor identity.

## Additional rule matches, not counted as standalone vulnerabilities

| ID | Priority | CWEs | Evidence | Assessment |
|---|---|---|---|---|
| O01 | LOW | 662, 820 | [NotificationService.cs](../ContosoUniversity/Services/NotificationService.cs), lines 20-23; [BaseController.cs](../ContosoUniversity/Controllers/BaseController.cs), line 12 | Per-controller check-then-create queue initialization can race on concurrent first requests when the queue is absent. Conditional startup availability issue; not dynamically reproduced against MSMQ. Confidence 8/10. |
| O02 | LOW | 477 | [WebMvcConfig.java](../asset-manager/web/src/main/java/com/microsoft/migration/assets/config/WebMvcConfig.java), lines 16-17, 49 | Deprecated MVC adapter APIs are used with warnings suppressed. The tool explicitly includes deprecated API use in this rule; deprecation alone does not establish a vulnerability. Confidence 10/10. |
| O03 | LOW | 681, 682 | [AbstractFileProcessingService.java](../asset-manager/worker/src/main/java/com/microsoft/migration/assets/worker/service/AbstractFileProcessingService.java), lines 109-119, 229-231 | A 1-by-1000 image produces a zero-width thumbnail target through integer truncation. Java rejects that allocation. Per-image processing failure, not demonstrated worker-wide denial of service. Arithmetic and rejection verified with JShell. Confidence 10/10. |

## CWE checklist completion

| Category | Total | FOUND | NOT_FOUND | PENDING |
|---|---:|---:|---:|---:|
| [Code quality](../.github/modernize/assessment/engines/security/cweChecklist/code-quality.json) | 16 | 8 | 8 | 0 |
| [Concurrency and synchronization](../.github/modernize/assessment/engines/security/cweChecklist/concurrency-synchronization.json) | 6 | 2 | 4 | 0 |
| [Credentials and secrets](../.github/modernize/assessment/engines/security/cweChecklist/credentials-secrets.json) | 5 | 4 | 1 | 0 |
| [File and path security](../.github/modernize/assessment/engines/security/cweChecklist/file-path-security.json) | 5 | 4 | 1 | 0 |
| [Injection attacks](../.github/modernize/assessment/engines/security/cweChecklist/injection-attacks.json) | 12 | 2 | 10 | 0 |
| [Memory safety](../.github/modernize/assessment/engines/security/cweChecklist/memory-safety.json) | 15 | 0 | 15 | 0 |
| **Total** | **59** | **20** | **39** | **0** |

The FOUND rules map to the findings/observations above. The NOT_FOUND decisions are:

- **Code quality:** CWE-130, CWE-456, CWE-457, CWE-570, CWE-571, CWE-665, CWE-783, CWE-1057. No supported length-field mismatch, uninitialized critical value, erroneous constant condition, initialization flaw, precedence flaw or prohibited data-manager bypass was established. Intentional console/menu loops have exit paths; the explicit Oracle raw-SQL demonstration is not evidence of a violated architectural policy.
- **Concurrency:** CWE-543, CWE-567, CWE-667, CWE-821. No independently supported unsafe singleton publication, mutable shared-field access, explicit lock misuse or incorrectly implemented synchronization was established. The MyBatis shared client is initialized through a Java static initializer. The queue creation race is recorded under the two matching missing/general-synchronization rules rather than every concurrency category.
- **Credentials:** CWE-321. AWS key placeholders are not evidence of a real embedded cryptographic key.
- **File/XML:** CWE-611. No path from attacker-supplied XML to an unsafe application XML parser was identified. Static local iBatis XML/DTD files alone do not establish XXE.
- **Injection:** CWE-77, CWE-78, CWE-79, CWE-88, CWE-90, CWE-91, CWE-502, CWE-564, CWE-643, CWE-652. No supported command/argument, LDAP, XML/XPath/XQuery, unsafe deserialization or Hibernate SQL-injection path was identified. The Java SQL paths use parameters. Student list pages/servlet and notification DOM insertion escape displayed data. Raw message expressions remain in add-form JSPs, but this review did not establish an attacker-controlled reachable rendering path; they are not promoted to a confirmed XSS finding. JSON conversion uses fixed target types without an inspected polymorphic type-enabling option.
- **Memory safety:** CWE-119, CWE-120, CWE-123, CWE-125, CWE-415, CWE-416, CWE-672, CWE-786, CWE-787, CWE-788, CWE-805, CWE-822, CWE-823, CWE-824, CWE-825. No first-party native/unsafe memory operations, unchecked native interfaces or supported use-after-release path were identified. This does not assess memory-safety bugs inside JVM/.NET runtimes, image codecs or third-party native libraries.

## Dependency CVE coverage

The root command `mvn dependency:list -DoutputAbsoluteArtifactId=true -DexcludeTransitive=true` **failed with exit code 1 because the workspace root has no POM**. No root wrapper was present. As required by the plan, the CVE batch immediately used local static parsing rather than fetching external parent/BOM metadata or attempting unrelated builds.

Six Maven manifests were inspected, including the Asset Manager parent, which declares no direct dependencies:

| Declaring module | Direct declarations | Version-resolved declarations | Unresolved declarations |
|---|---:|---:|---:|
| Asset Manager web | 10 | 1 | 9 |
| Asset Manager worker | 8 | 1 | 7 |
| RabbitMQ sender | 6 | 1 | 5 |
| Oracle todo API | 7 | 0 | 7 |
| SQL Server demo | 1 | 1 | 0 |
| **Total** | **32** | **4** | **28** |

The four resolved declarations produce three unique coordinates:

1. `software.amazon.awssdk:s3:2.25.13` - declared in both Asset Manager modules, resolved from explicit local dependency management/properties.
2. `org.projectlombok:lombok:1.18.24` - explicitly versioned in the RabbitMQ sender.
3. `com.microsoft.sqlserver:mssql-jdbc:10.2.0.jre11` - explicitly versioned in the SQL Server demo; one HIGH advisory match.

Versions for the remaining declarations are managed externally or not explicitly determinable from local declarations. They were not guessed or treated as safe. The raw CVE JSON contains the advisory match only, not a complete dependency inventory or a record proving every package was scanned.

## Validation and limits

- **Checklist validation:** **Passed.** All six JSON files were re-read after the write. The validation checked the exact expected 59 unique IDs, terminal statuses, required metadata/evidence shapes, nonempty evidence for FOUND, empty evidence for NOT_FOUND and existence of every workspace-relative evidence path. Result: 20 FOUND, 39 NOT_FOUND, 0 PENDING.
- **CVE persistence:** The result file is a JSON array containing the persisted FOUND entry for CVE-2025-59250.
- **Notification threshold reproduction:** `node -` with an inline VM harness loading the unchanged application script: **passed**. Five notifications returned; six hit the deliberate 100 ms execution cap. Deferred timers were stubbed without DOM mutation, matching their inability to run while synchronous JavaScript does not yield.
- **Filesystem/arithmetic checks:** An inline script piped to the installed JDK 21 `jshell.exe --feedback concise -`: **passed**, with `ABSOLUTE_ESCAPES=true`, `RELATIVE_ESCAPES=true`, `NARROW_IMAGE_TARGET_WIDTH=0`, `ZERO_WIDTH_REJECTED=true`. These checks performed no file writes.
- **Application tests/builds:** Not run. This was an assessment-only task with no application edits. The failed root dependency-resolution command is reported separately, not characterized as a successful build.
- **Live validation:** No applications, databases, queues or cloud resources were started or probed. No credential was tested. SQL injection, file deletion/overwrite, queue access and oversized-image exhaustion were not exercised against live services.
- **Residual uncertainty:** Deployment profiles, filesystem permissions, bucket policy, queue/network reachability and external hosting controls can change exploitability. Dependency coverage remains materially incomplete. A negative rule decision or absence of a reported CVE is not proof of safety.

## Suggested review order

1. Review the five HIGH findings, including deployment prerequisites, before choosing remediation scope.
2. Close dependency inventory gaps with effective per-project dependency resolution and a follow-up scan; assess non-Maven and transitive dependencies separately if required.
3. Prioritize the reproduced notification hang and upload/image resource boundaries next.
4. Review the low-priority observations separately from security fixes. No changes have been applied.
