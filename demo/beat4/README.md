# Beat 4 - Multi-agent Java modernization with gh-aw

This folder holds everything the demo needs. All prerequisites for running it live in this repository (your fork of `java-migration-copilot-samples`). The application being modernized is [`asset-manager/`](../../asset-manager).

## What the demo does

1. A human files a **Modernization Request** issue.
2. A **planner agent** writes a **Modernization Plan** and opens a plan pull request.
3. A human **merges the plan**. That merge is the first approval.
4. The pipeline's read-only agents assess the code, and the pipeline publishes one **Assessment Report** and **stops**. Nothing has changed yet.
5. A human **reviews and approves the Assessment Report**. That is the second approval.
6. The rest of the **pipeline of agents** upgrades `asset-manager` from Java 8 / Spring Boot 2.7 to Java 21 / Spring Boot 3.5, runs the tests, and opens an **Implementation Pull Request**.
7. A human reviews that pull request.

**Where the code lives.** The original Java 8 code stays on `main`. The modernized code lives on the branch `modernize/issue-<N>` and in the Implementation Pull Request. `main` changes only if a human merges that pull request. Do not merge it during the demo.

The pipeline is modelled on the plan, execute, validate loop of GitHub Copilot app modernization. It uses our own agents, not the product.

## What is automated and what is manual

| Item | Who does it | How |
|---|---|---|
| Install gh-aw `v0.89.21` or newer, GitHub CLI, Git | You, once | See Prerequisites |
| Create the fine-grained token (PAT) | **You (manual)** | Step 2. GitHub does not allow a script to create it |
| Enable Issues and Actions on the fork | Script | `setup.ps1` |
| Allow Actions to create pull requests | Script | `setup.ps1` |
| Store `COPILOT_GITHUB_TOKEN` as a secret | Script | `setup.ps1` asks you to paste the token; it is never printed |
| Create labels | Script | `setup.ps1` |
| Create the `assessment-review` approval environment, with you as required reviewer | Script | `setup.ps1` |
| Compile the agent workflows (`.lock.yml`) | Script | `setup.ps1` runs `gh aw compile` |
| Commit and push the demo files to your fork | Script | `setup.ps1`, after you confirm |
| Create the Modernization Request issue | Script | `new-request.ps1` |
| Plan, upgrade, code fixes, tests, review, draft PR | **Agents and Actions** | Automatic |
| **Approve the plan (merge the plan PR)** | **You (human gate 1)** | `gh pr merge` or the GitHub UI |
| **Approve the Assessment Report, before any code changes** | **You (human gate 2)** | Actions run > Review deployments |
| **Review the Implementation Pull Request** | **You (human gate 3)** | GitHub UI |

## Prerequisites

Run on your Windows machine. You do not need Visual Studio Code, a JDK, or Maven for the pipeline itself; it all runs in GitHub Actions.

```powershell
git --version
gh --version
gh auth status
gh aw version        # must be v0.89.21 or newer
```

You also need a GitHub account with an active Copilot license, and your fork of `Azure-Samples/java-migration-copilot-samples` cloned locally. If `gh aw` is missing or too old, follow "SAML fallback for gh-aw" in the demo kit `plan.md`.

## Step 1 - Open the fork

```powershell
Set-Location C:\Temp\GHDemo\JavaModernization\java-migration-copilot-samples
git branch --show-current     # main
git remote -v                 # origin = your fork, upstream = Azure-Samples
```

Every command below runs from this folder.

## Step 2 - Create the token (manual, about 2 minutes)

The agents call Copilot with a token you own.

1. Open this gh-aw link. It pre-fills the token name and the **Copilot Requests** permission, so you do not have to find it in the dropdown:

   <https://github.com/settings/personal-access-tokens/new?name=COPILOT_GITHUB_TOKEN&description=GitHub+Agentic+Workflows+-+Copilot+engine+authentication&user_copilot_requests=read>

2. **Resource owner**: your **personal user account**, not an organization. The Copilot Requests permission is not offered for organization-owned tokens. The account needs an active Copilot license.
3. **Repository access**: **Only select repositories**, then select `java-migration-copilot-samples` (your fork).
4. Open **Permissions** and select the **Account** tab (not **Repositories**). Confirm **Copilot Requests** is listed with access **Read**.

   If it is not listed: with the **Account** tab active, select **Add permissions**, search for `Copilot`, and tick **Copilot Requests**. On the **Repositories** tab the search only shows repository permissions such as "Copilot agent settings", which is the wrong one.
5. Choose a short expiration and select **Generate token**.
6. Copy it. It must start with `github_pat_`. A classic `ghp_` token does not work.

Do not give this token repository permissions. Actions uses its own token to write to the repository.

## Step 3 - Run the setup script

Preview first. This changes nothing on GitHub:

```powershell
.\demo\beat4\setup.ps1 -CheckOnly
```

Then run it for real. It asks for the token and for confirmation before it commits and pushes:

```powershell
.\demo\beat4\setup.ps1
```

The compile step takes about a minute. The script ends with a table. Every row must be `OK` or `FIXED`. A `MANUAL` row tells you exactly what to do.

## Step 4 - Pre-run the demo

### 4.1 Create the request

```powershell
.\demo\beat4\new-request.ps1
```

The planner agent, [modernize-planner.md](../../.github/workflows/modernize-planner.md), waits for an issue that starts with `/modernize-plan` (its `slash_command` trigger, lines 5-7). `new-request.ps1` puts that line first in the issue body.

### 4.2 Watch the planner and review the plan

```powershell
gh run list --workflow modernize-planner.lock.yml --limit 3
gh pr list --search "[modernization-plan] in:title"
```

When the plan pull request appears in your fork on GitHub, open **Files changed** and review `docs/modernization/requests/<N>-asset-manager-java-upgrade.md`. It is the only file in that PR, and the folder does not exist on `main` until the plan is merged. Check that it has the Java 8 / Spring Boot 2.7 baseline, the Java 21 / Spring Boot 3.5 target, the execution steps, and the exclusions (no Azure, containers or deployment).

### 4.3 Approve the plan (human gate)

Merge the plan PR into `main` of your fork. It adds only the plan file (Markdown, no code). The modernized code goes to a separate branch, `modernize/issue-<N>`, so `main` keeps the original Java 8 app.

In the GitHub UI, select **Squash and merge**, then **Confirm**. Or run:

```powershell
$planPr = gh pr list --repo lenvolk/java-migration-copilot-samples --search "[modernization-plan] in:title" --state open --json number --jq '.[0].number'
gh pr merge $planPr --repo lenvolk/java-migration-copilot-samples --squash --delete-branch
```

### 4.4 Watch the pipeline

```powershell
gh run list --workflow modernize-pipeline.yml --limit 3
gh run watch
```

Or open **Actions > modernize-pipeline** on GitHub. The run graph shows the parallel lanes. The pull request tracker comment shows each stage's status.

Each agent has one name everywhere: workflow file, Actions sidebar, run-graph job and custom agent (for example `modernize-code-fixer`).

```text
prepare -> [ baseline-test | modernize-compat-analyst | modernize-dependency-analyst ]   parallel, read-only
        -> assessment-report -> assessment-approval                  HUMAN GATE: nothing has changed yet
        -> modernize-build-upgrader -> modernize-code-fixer        sequential, one branch
        -> [ verify-build | verify-static ] -> modernize-conformance-reviewer
        -> finalize
```

The run stops at `assessment-approval` and shows **Waiting for review**. Continue with 4.5.

### Models used by the agents

Each workflow selects a different model under `engine.model`, using the same Copilot engine and existing token.

| Workflow | Model ID | Why |
|---|---|---|
| `modernize-planner` | `claude-sonnet-4.6` | Balance reasoning and readable plan writing. |
| `modernize-compat-analyst` | `gpt-5.4-mini` | Smaller model for bounded, read-only source analysis. |
| `modernize-dependency-analyst` | `claude-haiku-4.5` | Lightweight model for dependency inventory and recommendations. |
| `modernize-build-upgrader` | `gpt-5-mini` | Smaller model for plan-guided Maven configuration edits. |
| `modernize-code-fixer` | `gpt-5.3-codex` | Coding-focused model for Java edits and the compile/test/fix loop. |
| `modernize-conformance-reviewer` | `gpt-5.4` | Reasoning-oriented model for comparing the plan, diff and evidence. |

These are demo choices, not benchmarks or guarantees. Plain Actions jobs use no model. Compilation succeeds on gh-aw v0.89.21, but model access depends on the token owner, policy and availability for the gh-aw integration. Rehearse a fresh full run before presenting this model mix. Previous successful runs do not validate the new selections.

See the [gh-aw engine reference](https://github.github.com/gh-aw/reference/engines/). After changing a model, run `gh aw compile` and commit both source and lock files.

### 4.5 Review and approve the Assessment Report (human gate)

About 5 to 15 minutes after the plan merge, the analysts finish and the run waits for you. The report is the answer to "what will change, and how?" before any code is touched.

1. Open the Implementation Pull Request (draft) and read the comment **Assessment report**. It has the baseline test result, the source compatibility findings per file, the dependency decisions per artifact, and what each later job will do. The `modernize-compat-analyst` and `modernize-dependency-analyst` comments hold the same text as raw agent output. The report is also on the run summary page and downloadable as the `assessment-report` artifact.
2. Check that the findings match the plan, and that the proposed changes stay in scope.
3. Open the run (**Actions > modernize-pipeline**), select **Review deployments**, tick `assessment-review`, and select **Approve and deploy**. Select **Reject** to stop; the branch then has no application changes.

The report comment records who approved. The tracker row **Assessment review** turns green and the code-writing agents start.

### 4.6 Review the result (human gate)

Open the Implementation Pull Request (`[modernization] Upgrade Asset Manager ...`). Show:

- The tracker comment: baseline versus final tests.
- The agent comments: `modernize-compat-analyst`, `modernize-dependency-analyst`, `modernize-conformance-reviewer`.
- The diff: build files first, then `javax` to `jakarta`.
- The `modernize-conformance-reviewer` verdict: `Verdict: PASS`.

To show the original and the modernized code side by side without merging:

```powershell
git fetch origin
git diff --stat main...origin/modernize/issue-<N>
```

**Do not merge it.** `main` keeps the original Java 8 code, and the modernized code stays on `modernize/issue-<N>`.

## Timeline (estimates; record your own during the pre-run)

| Stage | Typical time |
|---|---|
| `modernize-planner` | 5 to 10 minutes |
| Parallel analysis and baseline tests | 5 to 15 minutes |
| Wait for your approval of the Assessment Report | as long as you take |
| `modernize-build-upgrader`, `modernize-code-fixer` | 15 to 40 minutes |
| Verification and review | 10 to 20 minutes |

## Recovery

Each stage is its own job or workflow, so a failure stops the pipeline at that stage and keeps earlier work on the branch.

1. Open the failed run in **Actions** and read the failed job.
2. Select **Re-run failed jobs**. Only the failed stage and the stages after it run again.
3. To run one agent alone, dispatch it directly. Example for `modernize-code-fixer`:

   ```powershell
   gh workflow run modernize-code-fixer.lock.yml `
     -f issue_number=<N> -f pr_number=<PR> `
     -f branch=modernize/issue-<N> `
     -f plan_path=docs/modernization/requests/<N>-asset-manager-java-upgrade.md
   ```

4. If the pipeline stopped after the plan merge and never started, dispatch it with the plan path:

   ```powershell
   gh workflow run modernize-pipeline.yml `
     -f plan_path=docs/modernization/requests/<N>-asset-manager-java-upgrade.md
   ```

## Reset

Closes all open issues and PRs, deletes every branch except `main`, and deletes all workflow runs. Merged plans on `main` stay.

```powershell
cd C:\Temp\GHDemo\JavaModernization\java-migration-copilot-samples
.\demo\beat4\reset.ps1          # preview, changes nothing
.\demo\beat4\reset.ps1 -Full    # reset; type the repo name to confirm
```

Keep your pre-run until after the customer meeting.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `setup.ps1` reports `Issues - MANUAL` or `Actions - MANUAL` | Enable them in the fork's Settings, then re-run. Forks start with both off |
| `gh` asks "Select a repo" (Multiple remotes detected) | Choose `lenvolk/java-migration-copilot-samples` (your fork), never `Azure-Samples/...`. `setup.ps1` runs `gh repo set-default` so `gh workflow`, `gh run` and `gh pr` stop asking. `gh secret` always needs `--repo`: `gh secret list --repo lenvolk/java-migration-copilot-samples` |
| `/modernize-plan` does nothing | The issue body must start with `/modernize-plan`. Confirm Actions is enabled and `COPILOT_GITHUB_TOKEN` is set |
| Run fails on the Copilot token | Use a fine-grained `github_pat_` token owned by your user account (not an organization) with **Account permissions: Copilot Requests: Read**. Re-run `gh secret set COPILOT_GITHUB_TOKEN --repo lenvolk/java-migration-copilot-samples` |
| Plan PR is not created | Settings > Actions > General > Allow GitHub Actions to create and approve pull requests |
| Pipeline did not start after the merge | The plan PR title must start with `[modernization-plan]` and change a file under `docs/modernization/requests/`. Otherwise dispatch it (see Recovery) |
| `Branch modernize/issue-<N> already exists` | Run `reset.ps1 -Full`, then create a new request |
| `verify-build` fails on tests | Compare with the baseline in the tracker comment. Re-run `modernize-code-fixer` |
| The run shows **Waiting** at `assessment-approval` | Expected. It is the human gate. Open the run, select **Review deployments** and approve (4.5) |
| No **Review deployments** button | You are not a required reviewer of `assessment-review`, or the environment is missing. Run `.\demo\beat4\setup.ps1`. Environments with reviewers need a public repository or a paid plan |
| `assessment-report` fails with `no required reviewer` or `does not exist` | The approval environment would not pause. Run `.\demo\beat4\setup.ps1`, then re-run the failed jobs |
| `assessment-report` fails with `No comment from modernize-...-analyst` | An analyst did not post its comment. Re-run that analyst, then re-run `assessment-report` |
| Agent cannot download Maven dependencies | The workflow allows the `java` network ecosystem. Check the agent log for a blocked domain and add it under `network.allowed` in that agent's workflow `.md`, then recompile |
| An agent's comment shows another agent's content, or `safe_outputs` fails with `No handler loaded for type` | Artifact name collision. Each worker needs a unique `stage` input (already set). If you add a worker, give it its own default |
| `gh extension upgrade aw` fails with SAML | Ignore it if `gh aw version` is v0.89.21 or newer |

## Files in this repository

| Path | Purpose |
|---|---|
| `demo/beat4/setup.ps1` | One-time setup and checks. Also pins the `gh` default repository to your fork |
| `demo/beat4/new-request.ps1` | Creates the Modernization Request issue |
| `demo/beat4/reset.ps1` | Previews or fully resets the fork (keeps `main`) |
| `demo/beat4/modernization-request.md` | Issue body used by `new-request.ps1` |
| `.github/workflows/modernize-planner.md` | Planner agent workflow (Stage 2) |
| `.github/workflows/modernize-pipeline.yml` | Orchestrating pipeline (Stage 3) |
| `.github/workflows/modernize-*-analyst.md`, `-build-upgrader.md`, `-code-fixer.md`, `-conformance-reviewer.md` | Five agent workflows, each named like its agent |
| `.github/agents/modernize-*.agent.md` | The five agent role definitions |
| `.github/skills/java-modernization/` | Plan format and boundaries (planner) |
| `.github/skills/java-upgrade-rules/` | Shared rules for the upgrade agents |
| `.github/scripts/` | Tracker comment, assessment report and test-result helpers |
| `*.lock.yml` | Generated by `gh aw compile`. Never edit by hand |
