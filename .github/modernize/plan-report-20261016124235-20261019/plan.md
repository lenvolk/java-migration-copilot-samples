# Modernization Plan: Selected assessment findings

**Project**: Five Java migration applications; seven security-review applications
**Assessment**: `report-20261016124235`
**Status**: **BLOCKED DRAFT — review only; do not execute.**

## Technical Framework

- Source report: `.github\modernize\assessment\reports\report-20261016124235\report.json`.
- Report status is `cancelled`; its selected findings are leads, not proof of
  assessment completeness. No assessment was rerun.
- `asset-manager`: Maven reactor with `web` and `worker`; Java 8,
  Spring Boot 2.7.18, PostgreSQL/JPA, Spring AMQP and AWS SDK S3.
- `mi-sql-public-demo`: standalone Maven/JDBC, Java 17, SQL Server driver
  10.2.0.jre11; already requests managed-identity authentication.
- `rabbitmq-sender`: Maven, Java 17, Spring Boot 3.3.0; already uses Service Bus.
- `todo-web-api-use-oracle-db`: Maven, Java 17, Spring Boot 3.2.4, Oracle/JPA.
- `jakarta-ee\student-web-app`: Ant/WAR, Java 11 source/target, Open Liberty,
  Spring 5.3.23 bundled JARs, MySQL/JNDI, JavaMail and Log4j configuration.
- No root aggregator unifies these applications. `ContosoUniversity` and
  `Malshinon` have their own `.csproj`, `.sln` and `packages.config` files and
  existing CWE evidence in the report. They are included in future targeted
  security/CVE work, not in Java/cloud transforms or Java integration baseline.
  Their reported evidence paths were checked for existence, not audited.

## Overview

Plan application changes for the selected database, messaging, storage, mail,
logging, build-tool and credential findings. Preserve each sample's behavior
and independent build boundary. De-duplicate credentials and localhost changes
into the service migration that owns them; verify residual findings once in
the security work. Do not copy retired AWS or broker secrets into Key Vault.

This is planning only. No application code, dependencies, environment, cloud
resources, Git history or pull requests were changed. No provisioning,
deployment, containerization, database data transfer or production cutover is
authorized by this plan.

The project `java-modernization` skill is not selected: it fixes Asset Manager
to Java 21/Boot 3.5, neither an approved target nor this request's full scope.
Pattern names are not skills; only actual matching skill definitions are
assigned in `.metadata\tasks.json`.

## Migration Impact Summary

Aliases: AM = `asset-manager` (web + worker); ST = `jakarta-ee\student-web-app`;
TD = `todo-web-api-use-oracle-db`; SQ = `mi-sql-public-demo`;
RM = `rabbitmq-sender`. MI = managed identity; KV = Key Vault.

| App | Current | Target | Authentication | Comment |
|-----|---------|--------|----------------|---------|
| AM | PostgreSQL | Azure PostgreSQL | MI | Both modules |
| AM | RabbitMQ | Service Bus | MI default | Producer + workers |
| AM | S3 + AWS region | Blob + Azure config | MI default | Remove AWS keys |
| ST | MySQL + Liberty JNDI | Azure MySQL | Open decision | Keep JNDI contract |
| ST | JavaMail | ACS Email | MI default | Student notification |
| ST | Ant + file logging | Maven + console | N/A | Preserve WAR |
| TD | Oracle | PostgreSQL | Open decision | Hosting unresolved |
| AM/ST/TD | Residual secrets | KV / no hardcodes | MI | No retired keys |
| SQ | Azure SQL with MI | Already satisfied | MI already | No SQL transform |
| RM | Service Bus | Already migrated | Existing | No AMQP transform |

## Ordered Phases & Dependencies

13 proposed tasks: **1 upgrade, 9 transform, 1 setupBaseline, 1 security,
1 integrationTest**; no infrastructure, deployment or containerization tasks.

1. Resolve the gates below and obtain plan review approval before any execution.
2. Approved Java upgrade is first in the task list. A frozen baseline snapshot
   of `.` is an independent, dependency-free task; it includes only the five
   Java applications and excludes Git metadata, reports and this plan folder.
3. Chain all code changes: Java → Ant/Maven → AM PostgreSQL → ST MySQL/JNDI →
   TD Oracle/PostgreSQL → AM messaging → AM storage/region → ST mail →
   ST console logging → residual credentials. No code migrations run in parallel.
4. Security follows every upgrade/transform. Mock integration verification
   converges on baseline, every code task and security, verifying the final code.
   Mock success does not validate real Azure access, identity/RBAC or delivery.

Detailed task requirements, source locations, issue IDs and future acceptance
checks are in `.metadata\tasks.json`, not duplicated here.

## Assessment Traceability & Verified Scope

All rule IDs below refer to the original report. Config values were withheld.
Category names and original solution strings, including kbIds, are preserved in
the corresponding task requirements.

| Selected category | Verified evidence / disposition | Owner |
|---|---|---|
| PostgreSQL database | AM configs lines 20/17; both module POMs/JPA | 004 |
| MySQL database | ST compose; Liberty dataSource and MySQL library | 005 |
| Local Credential | AM configs and TD YAML password keys | 011 |
| Microsoft SQL database | SQ `MainSQL.java:32` already selects MI | Skip transform |
| Openliberty Database | ST `web.xml:64-69`, `sql-map-config.xml:9-10` | 005 |
| Spring AMQP RabbitMQ | AM configs, RabbitTemplate, RabbitListener | 007 |
| AWS S3 | AM AWS configs/services and S3 dependency in both POMs | 008 |
| AWS Region Configuration | AM `aws.region` and `Region.of` in both modules | 008 |
| Oracle database | TD YAML; schema, repository and OracleSqlDemonstrator | 006 |
| Hardcoded Credential | AM broker/ST mail defaults; AWS placeholders only | 011 |
| Localhost | AM DB/broker, TD DB, ST mail; merge into service owners | 004/006/007/009 |
| Logging Management | ST `resources\log4j.properties:10-15` rolling appender | 010 |
| JavaMail | ST mailSession; AddStudentServlet imports/lookup/send | 009 |
| Java Version Upgrade | AM Java 8; SQ/RM/TD Java 17 in current POMs | 001, gated |
| Ant build tool | ST `build.xml`; Java 11 compile and WAR targets | 003 |

Exclusions and de-duplication:

- SQL rule `azure-database-microsoft-sql-03000`, incident
  `c6069640-80eb-4b44-84a6-9a848ccd8fa0`: database exists, but the selected
  password-to-MI transformation is already present in this plain-JDBC app.
  Original selection: Category: "Database Migration (Microsoft SQL)";
  Issues: [Microsoft SQL database found]; Solutions:
  [Secure Azure SQL Database with Managed Identity [kbId: mi-azure-sql]].
  Do not apply a Spring Boot SQL migration skill. SQ remains in Java/security
  and baseline scope; no real SQL authentication test has been run.
- RM has ServiceBusTemplate and Service Bus dependencies/configuration, not an
  extant AMQP source. AMQP report incidents are AM-only; do not remigrate RM.
- Unlocated incidents `5f2216ff-6919-4443-abbe-2bb5a837ffbf` (PostgreSQL) and
  `29dd4fe3-fa01-41be-86ca-ce208563e69b` (MySQL) do not establish extra projects.
  Their coverage is accounted for by the verified located occurrences.
- SQ Java incidents `dc88cf5a-c03f-4005-9885-67530e6cf6f3` and
  `74d6012b-01b4-4fe1-9784-5c5845343bdf` are one upgrade scope, not two tasks.
- AWS credential incidents `01e821bd-c2cd-409d-9f49-eda1f54f6979` and
  `8d007422-1582-437c-949e-df2ab607e127` point to placeholder AWS secret values,
  not verified exposed credentials. No secret rotation/KV population is
  justified by those values. Task 008 removes the obsolete settings; task 011
  records their disposition alongside actual literal/default credential keys.
- ST compose line 18 is an internal MySQL container healthcheck, not an
  application localhost endpoint. Preserve local-dev healthchecks; move only
  active production service references. ST DB already uses environment-backed
  JNDI configuration; migrate that existing boundary, not a new data layer.
- `spring-boot-to-azure-restricted-config-01000` was not selected and is excluded.
- ST Java 11 is verified Ant context, not an additional reported Java-upgrade
  incident. Preserve it during build conversion unless separately approved.

## Security Compliance

Future scans/remediation only; no new vulnerability findings are asserted.
The security task covers all five Java applications **and the report-referenced
ContosoUniversity/Malshinon security scopes**, direct/transitive build
dependencies, build plugins and bundled ST JARs. Do not silently discard
C#/JavaScript evidence: the report references ContosoUniversity for CWE-606,
CWE-835, CWE-662, CWE-820, CWE-732, CWE-778 and CWE-99; Malshinon for CWE-772,
CWE-775 and CWE-89. Preserve those original evidence links for future
verification, not automatic acceptance as confirmed vulnerabilities.
Use the security template's
`validate-cves-and-fix` builtin guidance at execution (the supplied security
task schema has no `skills` field). Retain existing .NET runtime/build targets;
no .NET upgrade or Azure transformation is added. Future security remediation
must run the corresponding impacted .NET build/tests, not a Java runner.
The source report also lists `CVE-2025-59250`, but provides no file evidence or
evidence explanation for it; confirm component/version/applicability during
the future scan rather than asserting it affects a current module.

Required future CWE coverage: **CWE-477, CWE-606, CWE-681, CWE-682, CWE-772,
CWE-775, CWE-789, CWE-835, CWE-662, CWE-820, CWE-259, CWE-732, CWE-778,
CWE-798, CWE-22, CWE-23, CWE-36, CWE-434, CWE-89, CWE-99**.
Record a scope-specific scan/review disposition for each ID; fix confirmed
findings and add focused regression tests. An absent finding is not proof that
unavailable or unscanned code is safe. CWE-259/CWE-798 share the credential task's
implementation; the final security pass verifies it without duplicate rewrites.

CVE acceptance: resolve all confirmed applicable CVEs, prefer minimum patched
versions, document any necessary major upgrade/current and target versions plus
breaking-change risk, and rescan the final resolved graph and bundled artifacts.
Record scanner/version/advisory date, coverage, before/after results, exclusions
and evidence. Scanner failures, uncovered artifacts and unresolved confirmed
CVEs are blockers, not passing results. Any false-positive/not-applicable
disposition requires evidence; no fabricated CVE list or clean-scan assertion.
Future builds, impacted tests and final mock integration verification must pass.

## Open Questions & Questionnaire

`ask_user` was searched for but is unavailable in this non-interactive session.
No clarification answers have been invented. Defaults below are planning
defaults, not execution consent.

- [ ] **Blocking:** Which explicit Java target is approved for AM, SQ, RM and TD?
  Supported guideline options: 11, 17, 21, 25; do not downgrade current Java 17
  samples. “Latest LTS” is not an approved number. Recheck compatibility before
  finalizing. No Spring Boot/Spring/Jakarta upgrade is authorized; ask for
  separate approval if the chosen JDK requires one.
- [ ] **Blocking:** For Oracle → PostgreSQL, approve hosting/product/version
  (Azure Database for PostgreSQL or another PostgreSQL target) and authentication.
  No Oracle data movement/cutover or provisioning is implied.
- [ ] **Blocking:** Approve the Open Liberty → Azure MySQL authentication
  strategy while retaining JNDI. `migration-mi-mysql` targets Spring Boot and
  is not a fully matched skill for this app.
- [x] Q: Provision infrastructure? → A: No; user requested planning/migration
  scope only. Existing compose files are source evidence/local-dev fixtures,
  not an Azure environment supplied for this plan.
- [x] Q: Integration testing? → A: Inferred questionnaire default: **Yes — Mock
  mode**, since no Azure environment was supplied. Include setupBaseline and
  integrationTest; no tests are run while planning.
- [x] Q: Security/CVE? → A: Explicit custom requirements: all 20 CWEs above and
  CVE scan/remediation, with duplicate credential work merged.
- [x] Q: Deployment? → A: No deployment; migration only.
- [x] Q: Containerization? → A: No; not requested.
- [ ] Review the draft/defaults and resolve all gates before asking to execute.

## Planning Validation & Blockers

See `.metadata\validation.json` for exact checks/results.
JSON syntax, task IDs/dependency graph, original selected-category coverage,
all 20 CWE IDs and CVE acceptance coverage were checked without application
builds/tests, cloud calls or vulnerability scans.

**Supplied-schema defect:** standard JSON Schema validation cannot accept any
nonempty task list. Every task uses `allOf`; `taskBase.additionalProperties:
false` rejects task-specific fields, while the task-specific branch's own
`additionalProperties: false` rejects required base fields such as `id`,
`description` and `requirements`. In particular, upgrade requires
`successCriteria`, which taskBase forbids. The unmodified supplied-schema
validation therefore **FAILS**. The schema file was not edited.

An in-memory composition repair can validate the intended combined field sets,
but is supplemental, not a claim of conformance to the supplied schema.
The persistent task document is a **partial draft, not execution-ready** until
the schema owner corrects the contract and open target decisions are approved.

No application builds/tests, baseline generation, integration tests, CVE/CWE
scans, migrations, resource provisioning, commits or PRs were run.
The worktree was clean before planning. Three artifacts were created in this
plan folder. At the user's follow-up request, a sanitized
`assessment-report.md` was also saved alongside the original report JSON;
all 18 rules, 49 incident references and 21 security entries/evidence paths
were checked against the existing report, which was not changed or rerun.
The saved review report is ignored by the existing assessment `.gitignore`;
it persists on disk and is registered for review, but was not force-added.
