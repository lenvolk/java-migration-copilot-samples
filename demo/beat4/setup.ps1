<#
.SYNOPSIS
  One-time setup of the Beat 4 modernization demo in YOUR fork of java-migration-copilot-samples.

.DESCRIPTION
  Checks prerequisites, configures the fork (Issues, Actions, PR permissions, labels),
  stores the Copilot token secret, compiles the gh-aw workflows, and (after you confirm)
  commits and pushes the Beat 4 files to main of your fork.

  Run it from anywhere inside the cloned fork:
    .\demo\beat4\setup.ps1

  Safe to re-run. It never prints the token and refuses to run against the upstream repository.

.PARAMETER SkipSecret
  Do not prompt for COPILOT_GITHUB_TOKEN (use when the secret is already set).

.PARAMETER Yes
  Skip the confirmation before commit and push.

.PARAMETER CheckOnly
  Read-only report: verifies tools, the fork, settings, the secret, and compiles the workflows.
  Changes nothing on GitHub and does not commit.
#>
[CmdletBinding()]
param(
  [switch]$SkipSecret,
  [switch]$Yes,
  [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
$MinAwVersion = [version]'0.89.21'
$Upstream = 'Azure-Samples/java-migration-copilot-samples'
$results = New-Object System.Collections.Generic.List[object]

function Add-Result($Step, $Status, $Detail) {
  $results.Add([pscustomobject]@{ Step = $Step; Status = $Status; Detail = $Detail }) | Out-Null
  $color = switch ($Status) { 'OK' { 'Green' } 'FIXED' { 'Cyan' } 'MANUAL' { 'Yellow' } default { 'Red' } }
  Write-Host ("[{0}] {1} - {2}" -f $Status, $Step, $Detail) -ForegroundColor $color
}

function Stop-Setup($Message) {
  Write-Host ''
  Write-Host "Setup stopped: $Message" -ForegroundColor Red
  exit 1
}

# Native commands may write to stderr; that must not abort the script in Windows PowerShell 5.1.
function Invoke-Native($ScriptBlock) {
  $previous = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { $output = & $ScriptBlock 2>&1 | ForEach-Object { "$_" } | Out-String } finally { $ErrorActionPreference = $previous }
  return [pscustomobject]@{ Ok = ($LASTEXITCODE -eq 0); Output = $output }
}

# 1. Location
$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) { Stop-Setup 'Run this script from inside the cloned fork.' }
Set-Location $repoRoot
if (-not (Test-Path 'asset-manager\pom.xml') -or -not (Test-Path '.github\workflows\modernize-pipeline.yml')) {
  Stop-Setup 'asset-manager\ or the Beat 4 workflow files are missing. Are you in the java-migration-copilot-samples fork?'
}
Add-Result 'Location' 'OK' $repoRoot

# The target is always origin, so the two remotes (origin and upstream) never confuse the GitHub CLI.
$originUrl = git remote get-url origin
if ($originUrl -notmatch 'github\.com[:/](?<owner>[^/]+)/(?<name>[^/]+?)(\.git)?$') { Stop-Setup "Cannot read the GitHub repository from origin: $originUrl" }
$target = "$($Matches.owner)/$($Matches.name)"
if ($target -eq $Upstream) { Stop-Setup "origin points at the upstream repository $Upstream. Clone your fork instead." }

# 2. Tools
foreach ($tool in 'git', 'gh') {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { Stop-Setup "$tool is not installed." }
}
if (-not (Invoke-Native { gh auth status }).Ok) { Stop-Setup 'GitHub CLI is not signed in. Run: gh auth login' }
Add-Result 'GitHub CLI' 'OK' 'signed in'

$awOut = (Invoke-Native { gh aw version }).Output
if ($awOut -notmatch 'v?(\d+\.\d+\.\d+)') { Stop-Setup 'gh-aw is not installed. Run: gh extension install github/gh-aw' }
$awVersion = [version]$Matches[1]
if ($awVersion -lt $MinAwVersion) { Stop-Setup "gh-aw $awVersion is older than $MinAwVersion. See plan.md, SAML fallback for gh-aw." }
Add-Result 'gh-aw' 'OK' "v$awVersion"

# 3. Target repository must be the user's fork, never upstream
$repo = gh repo view $target --json nameWithOwner,isFork,parent,hasIssuesEnabled | ConvertFrom-Json
if ($repo.nameWithOwner -eq $Upstream) { Stop-Setup "origin points at the upstream repository $Upstream. Use your fork." }
if (-not $repo.isFork) { Stop-Setup "$target is not a fork." }
Add-Result 'Target repository' 'OK' "$target (fork of $($repo.parent.owner.login)/$($repo.parent.name))"

# With two remotes (origin and upstream) gh asks "Select a repo" on many commands. Pin the default to the fork (local setting only).
$default = Invoke-Native { gh repo set-default $target }
if ($default.Ok) { Add-Result 'gh default repository' 'OK' "$target (no more 'Select a repo' prompts)" }
else { Add-Result 'gh default repository' 'MANUAL' "Run: gh repo set-default $target" }

# 4. Fork settings (forks start with Issues and Actions turned off)
if ($CheckOnly) {
  $state = if ($repo.hasIssuesEnabled) { 'OK' } else { 'MANUAL' }
  Add-Result 'Issues' $state "enabled = $($repo.hasIssuesEnabled)"
  $wf = (Invoke-Native { gh api "repos/$target/actions/permissions/workflow" }).Output | ConvertFrom-Json
  $state = if ($wf.can_approve_pull_request_reviews) { 'OK' } else { 'MANUAL' }
  Add-Result 'Actions can create pull requests' $state "enabled = $($wf.can_approve_pull_request_reviews)"
}
else {
  gh repo edit $target --enable-issues | Out-Null
  Add-Result 'Issues' 'FIXED' 'enabled'

  $r = Invoke-Native { gh api -X PUT "repos/$target/actions/permissions" -F enabled=true -f allowed_actions=all }
  if ($r.Ok) { Add-Result 'Actions' 'FIXED' 'enabled, all actions allowed' }
  else { Add-Result 'Actions' 'MANUAL' 'Settings > Actions > General > Allow all actions (API call was rejected)' }

  $r = Invoke-Native { gh api -X PUT "repos/$target/actions/permissions/workflow" -f default_workflow_permissions=read -F can_approve_pull_request_reviews=true }
  if ($r.Ok) { Add-Result 'Actions can create pull requests' 'FIXED' 'enabled' }
  else { Add-Result 'Actions can create pull requests' 'MANUAL' 'Settings > Actions > General > Workflow permissions > Allow GitHub Actions to create and approve pull requests' }

  # 5. Labels
  $labels = @(
    @{ n = 'modernization-request'; c = '5319e7' },
    @{ n = 'modernization'; c = '1d76db' },
    @{ n = 'ready-for-human-review'; c = '0e8a16' },
    @{ n = 'needs-attention'; c = 'd93f0b' }
  )
  foreach ($l in $labels) { gh label create $l.n --color $l.c --force --repo $target | Out-Null }
  Add-Result 'Labels' 'FIXED' (($labels | ForEach-Object { $_.n }) -join ', ')
}

# 5b. Approval gate. The pipeline pauses in this environment until a required reviewer approves the assessment report.
# GitHub creates a missing environment without protection on first use, which would skip the pause, so it is created here.
$gateName = 'assessment-review'
$gateRules = 0
$gate = Invoke-Native { gh api "repos/$target/environments/$gateName" --jq '[.protection_rules[]? | select(.type == "required_reviewers")] | length' }
if ($gate.Ok) { [void][int]::TryParse($gate.Output.Trim(), [ref]$gateRules) }
if ($gateRules -ge 1) {
  Add-Result 'Approval environment' 'OK' "$gateName requires a reviewer"
}
elseif ($CheckOnly) {
  Add-Result 'Approval environment' 'MANUAL' "$gateName is missing or has no required reviewer. Run setup.ps1 without -CheckOnly"
}
else {
  $userId = [int](gh api user --jq .id)
  $payload = @{ reviewers = @(@{ type = 'User'; id = $userId }); prevent_self_review = $false } | ConvertTo-Json -Depth 5 -Compress
  $r = Invoke-Native { $payload | gh api -X PUT "repos/$target/environments/$gateName" --input - }
  if ($r.Ok) { Add-Result 'Approval environment' 'FIXED' "$gateName created, you are the required reviewer" }
  else { Add-Result 'Approval environment' 'MANUAL' "Settings > Environments > New environment '$gateName' > Required reviewers: add yourself. Environments with reviewers need a public repository or a paid plan" }
}

# 6. Copilot token secret
$hasSecret = (gh secret list --repo $target --json name | ConvertFrom-Json | Where-Object name -eq 'COPILOT_GITHUB_TOKEN')
if ($hasSecret) {
  Add-Result 'COPILOT_GITHUB_TOKEN' 'OK' 'already set'
}
elseif ($SkipSecret -or $CheckOnly) {
  Add-Result 'COPILOT_GITHUB_TOKEN' 'MANUAL' 'not set. Create the PAT (demo\beat4\README.md, step 2) and run: gh secret set COPILOT_GITHUB_TOKEN'
}
else {
  Write-Host ''
  Write-Host 'Paste the fine-grained PAT (starts with github_pat_). Input is hidden.' -ForegroundColor Yellow
  $secure = Read-Host 'COPILOT_GITHUB_TOKEN' -AsSecureString
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
  if (-not $plain.StartsWith('github_pat_')) { Stop-Setup 'The token must be a fine-grained PAT starting with github_pat_. Classic ghp_ tokens do not work.' }
  $plain | gh secret set COPILOT_GITHUB_TOKEN --repo $target
  $plain = $null
  Add-Result 'COPILOT_GITHUB_TOKEN' 'FIXED' 'stored as a repository secret'
}

# 7. Compile the gh-aw workflows
$compile = Invoke-Native { gh aw compile }
Write-Host $compile.Output
if (-not $compile.Ok) { Stop-Setup 'gh aw compile failed. Fix the error above and re-run.' }
$locks = @(Get-ChildItem .github\workflows -Filter 'modernize-*.lock.yml')
if ($locks.Count -lt 6) { Stop-Setup "Expected 6 compiled .lock.yml files, found $($locks.Count)." }
Add-Result 'gh aw compile' 'OK' "$($locks.Count) lock files"

if ($CheckOnly) {
  Write-Host ''
  Write-Host '=== Check-only summary (nothing was changed except regenerated lock files) ===' -ForegroundColor White
  $results | Format-Table -AutoSize
  exit 0
}

# 8. Commit and push to main of the fork
git fetch origin main --quiet
$branch = git branch --show-current
if ($branch -ne 'main') { Stop-Setup "Switch to main first (current branch: $branch)." }
$pending = git status --porcelain -- .github demo .gitattributes
if ($pending) {
  Write-Host ''
  Write-Host 'These Beat 4 files will be committed to main of your fork:' -ForegroundColor Yellow
  $pending | ForEach-Object { Write-Host "  $_" }
  if (-not $Yes) {
    $answer = Read-Host "Commit and push to origin/main of $target? (y/N)"
    if ($answer -notmatch '^(y|yes)$') { Add-Result 'Commit and push' 'MANUAL' 'skipped; run git add/commit/push yourself'; $pending = $null }
  }
  if ($pending) {
    git add .github demo .gitattributes
    git commit -m 'feat: add Beat 4 multi-agent Java modernization pipeline' | Out-Null
    git push origin main
    if ($LASTEXITCODE -ne 0) { Stop-Setup 'git push failed.' }
    Add-Result 'Commit and push' 'FIXED' 'pushed to origin/main'
  }
}
else {
  Add-Result 'Commit and push' 'OK' 'nothing to commit'
}

# 9. Verify GitHub sees the workflows
Start-Sleep -Seconds 5
$names = gh workflow list --repo $target --json name | ConvertFrom-Json | ForEach-Object { $_.name }
$expected = @('modernize-pipeline', 'modernize-planner', 'modernize-compat-analyst', 'modernize-dependency-analyst', 'modernize-build-upgrader', 'modernize-code-fixer', 'modernize-conformance-reviewer')
$missing = $expected | Where-Object { $names -notcontains $_ }
if ($missing) { Add-Result 'Workflows registered' 'MANUAL' "not visible yet: $($missing -join ', '). Wait a minute and run: gh workflow list" }
else { Add-Result 'Workflows registered' 'OK' "all $($expected.Count) modernize-* workflows visible in Actions" }

Write-Host ''
Write-Host '=== Summary ===' -ForegroundColor White
$results | Format-Table -AutoSize
if ($results | Where-Object Status -eq 'MANUAL') {
  Write-Host 'Complete the MANUAL items above before the pre-run.' -ForegroundColor Yellow
}
else {
  Write-Host 'Ready. Next: .\demo\beat4\new-request.ps1' -ForegroundColor Green
}
