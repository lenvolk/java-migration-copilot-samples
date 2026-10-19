<#
.SYNOPSIS
  Reset the fork for a fresh Beat 4 run.

.DESCRIPTION
  Run from the fork root: C:\Temp\GHDemo\JavaModernization\java-migration-copilot-samples

  No parameter : preview only. Shows what would be removed. Nothing changes.
  -Full        : closes all open issues and pull requests, deletes every remote
                 branch except main, and deletes all workflow runs. Asks to confirm.
  -Full -Force : same, without the confirmation prompt.

  Kept: main, its files, merged plans under docs/modernization/requests/,
  secrets, labels and settings. Plan files never conflict because each
  filename uses the issue number, and GitHub never reuses issue numbers.

    .\demo\beat4\reset.ps1
    .\demo\beat4\reset.ps1 -Full
#>
[CmdletBinding()]
param(
  [switch]$Full,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'
$Upstream = 'Azure-Samples/java-migration-copilot-samples'

$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) { throw 'Run this script from the fork root: C:\Temp\GHDemo\JavaModernization\java-migration-copilot-samples' }
Set-Location $repoRoot

$originUrl = git remote get-url origin
if ($originUrl -notmatch 'github\.com[:/](?<owner>[^/]+)/(?<name>[^/]+?)(\.git)?$') { throw "Cannot read the GitHub repository from origin: $originUrl" }
$target = "$($Matches.owner)/$($Matches.name)"
if ($target -eq $Upstream) { throw "origin points at the upstream repository $Upstream. Use your fork." }

# Windows PowerShell 5.1 returns a JSON array as one object; ForEach-Object unrolls it.
$issues = @(gh issue list --repo $target --state open --limit 500 --json number,title | ConvertFrom-Json | ForEach-Object { $_ })
$prs = @(gh pr list --repo $target --state open --limit 500 --json number,title,headRefName | ConvertFrom-Json | ForEach-Object { $_ })
$branches = @(git ls-remote --heads origin | ForEach-Object { ($_ -split "`t")[1] -replace '^refs/heads/', '' } | Where-Object { $_ -ne 'main' })
$runs = @(gh run list --repo $target --limit 1000 --json databaseId,status,workflowName | ConvertFrom-Json | ForEach-Object { $_ })

Write-Host "Repository: $target" -ForegroundColor Cyan
Write-Host ''
Write-Host "Open issues ($($issues.Count)):"
$issues | ForEach-Object { "  #$($_.number) $($_.title)" }
Write-Host "Open pull requests ($($prs.Count)):"
$prs | ForEach-Object { "  #$($_.number) $($_.headRefName) - $($_.title)" }
Write-Host "Branches other than main ($($branches.Count)):"
$branches | ForEach-Object { "  $_" }
Write-Host "Workflow runs ($($runs.Count)):"
$runs | Group-Object workflowName | ForEach-Object { "  $($_.Count) x $($_.Name)" }
Write-Host ''

if (-not $Full) {
  Write-Host 'Preview only. Nothing changed. To reset: .\demo\beat4\reset.ps1 -Full' -ForegroundColor Yellow
  return
}

if (-not $Force) {
  $answer = Read-Host "Type the repository name ($target) to reset it"
  if ($answer -ne $target) { Write-Host 'Cancelled. Nothing changed.' -ForegroundColor Yellow; return }
}

foreach ($pr in $prs) {
  # No --comment: a comment would fire the issue_comment trigger of modernize-assessment and create new runs.
  gh pr close $pr.number --repo $target 2>&1 | Out-Null
  Write-Host "Closed PR #$($pr.number)"
}

foreach ($issue in $issues) {
  gh issue close $issue.number --repo $target --reason 'not planned' 2>&1 | Out-Null
  Write-Host "Closed issue #$($issue.number)"
}

foreach ($branch in $branches) {
  gh api -X DELETE "repos/$target/git/refs/heads/$branch" --silent
  if ($LASTEXITCODE -ne 0) { Write-Warning "Could not delete branch $branch" } else { Write-Host "Deleted branch $branch" }
}

# Re-list after a pause so runs triggered by the steps above are deleted too.
Start-Sleep -Seconds 15
$runs = @(gh run list --repo $target --limit 1000 --json databaseId,status | ConvertFrom-Json | ForEach-Object { $_ })
foreach ($run in $runs) {
  if ($run.status -ne 'completed') {
    gh run cancel $run.databaseId --repo $target 2>$null | Out-Null
    gh run watch $run.databaseId --repo $target 2>$null | Out-Null
  }
  gh api -X DELETE "repos/$target/actions/runs/$($run.databaseId)" --silent
  if ($LASTEXITCODE -ne 0) { Write-Warning "Could not delete run $($run.databaseId)" }
}
Write-Host "Deleted $($runs.Count) workflow runs"

git fetch origin --prune --quiet
git switch main --quiet
git pull --ff-only --quiet
git branch --format '%(refname:short)' | Where-Object { $_ -ne 'main' } | ForEach-Object { git branch -D $_ --quiet }

Write-Host ''
Write-Host 'Reset complete. Only main remains.' -ForegroundColor Green
