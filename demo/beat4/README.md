# Beat 4 - Multi-agent Java modernization with gh-aw

This folder holds everything the demo needs. All prerequisites for running it live in this repository (your fork of `java-migration-copilot-samples`). The application being modernized is [`asset-manager/`](../../asset-manager).

## What the demo does

1. A human files a **Modernization Request** issue.
2. A **planner agent** writes a **Modernization Plan** and opens a plan pull request.
3. A human **merges the plan**. That merge is the approval.
4. A **pipeline of agents** upgrades `asset-manager` from Java 8 / Spring Boot 2.7 to Java 21 / Spring Boot 3.5, runs the tests, and opens an **Implementation Pull Request**.
5. A human reviews that pull request.

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
| Compile the agent workflows (`.lock.yml`) | Script | `setup.ps1` runs `gh aw compile` |
| Commit and push the demo files to your fork | Script | `setup.ps1`, after you confirm |
| Create the Modernization Request issue | Script | `new-request.ps1` |
| Plan, upgrade, code fixes, tests, review, draft PR | **Agents and Actions** | Automatic |
| **Approve the plan (merge the plan PR)** | **You (human gate)** | `gh pr merge` or the GitHub UI |
| **Review the Implementation Pull Request** | **You (human gate)** | GitHub UI |

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

### 4.2 Watch the planner and review the plan

```powershell
gh run list --workflow modernize-1-plan.lock.yml --limit 3
gh pr list --search "[modernization-plan] in:title"
```

When the plan pull request appears, open it and review `docs/modernization/requests/<N>-asset-manager-java-upgrade.md`. Check that it has the Java 8 / Spring Boot 2.7 baseline, the Java 21 / Spring Boot 3.5 target, the execution steps, and the exclusions (no Azure, containers or deployment).

### 4.3 Approve the plan (human gate)

```powershell
$planPr = gh pr list --search "[modernization-plan] in:title" --state open --json number --jq '.[0].number'
gh pr merge $planPr --squash --delete-branch
```

The merge starts the pipeline.

### 4.4 Watch the pipeline

```powershell
gh run list --workflow modernize-pipeline.yml --limit 3
gh run watch
```

Or open **Actions > Modernize Asset Manager - Pipeline** on GitHub. The run graph shows the parallel lanes. The pull request tracker comment shows each stage's status.

```text
prepare -> [ baseline-test | compat agent | deps agent ]    parallel
        -> build-upgrader agent -> code-fixer agent          sequential, one branch
        -> [ verify-build | verify-static ] -> review agent  parallel checks, then review
        -> finalize
```

### 4.5 Review the result (human gate)

Open the Implementation Pull Request (`[modernization] Upgrade Asset Manager ...`). Show:

- The tracker comment: baseline versus final tests.
- The agent comments (compatibility, dependencies, review).
- The diff: build files first, then `javax` to `jakarta`.
- The conformance review: `Verdict: PASS`.

To show the original and the modernized code side by side without merging:

```powershell
git fetch origin
git diff --stat main...origin/modernize/issue-<N>
```

**Do not merge it.** `main` keeps the original Java 8 code, and the modernized code stays on `modernize/issue-<N>`.

## Timeline (estimates; record your own during the pre-run)

| Stage | Typical time |
|---|---|
| Planner agent | 5 to 10 minutes |
| Parallel analysis and baseline tests | 5 to 15 minutes |
| Build Upgrader, Code Fixer | 15 to 40 minutes |
| Verification and review | 10 to 20 minutes |

## Recovery

Each stage is its own job or workflow, so a failure stops the pipeline at that stage and keeps earlier work on the branch.

1. Open the failed run in **Actions** and read the failed job.
2. Select **Re-run failed jobs**. Only the failed stage and the stages after it run again.
3. To run one agent alone, dispatch it directly. Example for the Code Fixer:

   ```powershell
   gh workflow run modernize-worker-codefix.lock.yml `
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

```powershell
.\demo\beat4\reset.ps1                  # lists runs, deletes nothing
.\demo\beat4\reset.ps1 -CloseRun <N>    # closes the PR and deletes modernize/issue-<N>
```

Keep your pre-run until after the customer meeting. Merged plan files stay on `main`; each new request has its own issue number.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `setup.ps1` reports `Issues - MANUAL` or `Actions - MANUAL` | Enable them in the fork's Settings, then re-run. Forks start with both off |
| `/modernize-plan` does nothing | The issue body must start with `/modernize-plan`. Confirm Actions is enabled and `COPILOT_GITHUB_TOKEN` is set |
| Run fails on the Copilot token | Use a fine-grained `github_pat_` token owned by your user account (not an organization) with **Account permissions: Copilot Requests: Read**. Re-run `gh secret set COPILOT_GITHUB_TOKEN` |
| Plan PR is not created | Settings > Actions > General > Allow GitHub Actions to create and approve pull requests |
| Pipeline did not start after the merge | The plan PR title must start with `[modernization-plan]` and change a file under `docs/modernization/requests/`. Otherwise dispatch it (see Recovery) |
| `Branch modernize/issue-<N> already exists` | Run `reset.ps1 -CloseRun <N>` or delete the branch, then re-run |
| `verify-build` fails on tests | Compare with the baseline in the tracker comment. Re-run the Code Fixer |
| Agent cannot download Maven dependencies | The workflow allows the `java` network ecosystem. Check the agent log for a blocked domain and add it under `network.allowed` in the worker `.md`, then recompile |
| `gh extension upgrade aw` fails with SAML | Ignore it if `gh aw version` is v0.89.21 or newer |

## Files in this repository

| Path | Purpose |
|---|---|
| `demo/beat4/setup.ps1` | One-time setup and checks |
| `demo/beat4/new-request.ps1` | Creates the Modernization Request issue |
| `demo/beat4/reset.ps1` | Lists or clears a run |
| `demo/beat4/modernization-request.md` | Issue body used by `new-request.ps1` |
| `.github/workflows/modernize-1-plan.md` | Planner agent workflow (Stage 2) |
| `.github/workflows/modernize-pipeline.yml` | Orchestrating pipeline (Stage 3) |
| `.github/workflows/modernize-worker-*.md` | Five agent workflows: compat, deps, upgrade, codefix, review |
| `.github/agents/modernize-*.agent.md` | The five agent role definitions |
| `.github/skills/java-modernization/` | Plan format and boundaries (planner) |
| `.github/skills/java-upgrade-rules/` | Shared rules for the upgrade agents |
| `.github/scripts/` | Tracker comment and test-result helpers |
| `*.lock.yml` | Generated by `gh aw compile`. Never edit by hand |
