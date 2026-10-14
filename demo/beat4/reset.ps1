<#
.SYNOPSIS
  Reset the fork so Beat 4 can be run again. Keeps your pre-run result unless you ask otherwise.

.DESCRIPTION
  Default (safe): only lists what exists. Nothing is deleted.
  -CloseRun <issue-number>: closes the Implementation PR and deletes the modernize/issue-<N> branch.
  Merged plan files stay on main on purpose; each new request gets its own issue number.

    .\demo\beat4\reset.ps1
    .\demo\beat4\reset.ps1 -CloseRun 12
#>
[CmdletBinding()]
param(
  [int]$CloseRun
)

$ErrorActionPreference = 'Stop'
$Upstream = 'Azure-Samples/java-migration-copilot-samples'

$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) { throw 'Run this script from inside the cloned fork.' }
Set-Location $repoRoot

$originUrl = git remote get-url origin
if ($originUrl -notmatch 'github\.com[:/](?<owner>[^/]+)/(?<name>[^/]+?)(\.git)?$') { throw "Cannot read the GitHub repository from origin: $originUrl" }
$target = "$($Matches.owner)/$($Matches.name)"
if ($target -eq $Upstream) { throw "origin points at the upstream repository $Upstream. Use your fork." }

Write-Host "Repository: $target" -ForegroundColor Cyan
Write-Host ''
Write-Host 'Modernization pull requests:'
gh pr list --repo $target --state all --search '[modernization' --json number,title,state,headRefName --template '{{range .}}  #{{.number}} {{.state}} {{.headRefName}} - {{.title}}{{"\n"}}{{end}}'
Write-Host ''
Write-Host 'Modernization branches:'
git ls-remote --heads origin 'modernize/*' | ForEach-Object { '  ' + ($_ -split "`t")[1] }

if ($CloseRun) {
  $branch = "modernize/issue-$CloseRun"
  $prNumber = gh pr list --repo $target --head $branch --state open --json number --jq '.[0].number'
  if ($prNumber) { gh pr close $prNumber --repo $target --comment 'Closed by reset.ps1 to rerun the demo.' | Out-Null }
  git push origin --delete $branch
  if ($LASTEXITCODE -ne 0) { throw "Could not delete $branch. It may not exist, or you may lack permission." }
  Write-Host "Closed the Implementation PR and deleted $branch." -ForegroundColor Green
}
else {
  Write-Host ''
  Write-Host 'Nothing deleted. To clear one run: .\demo\beat4\reset.ps1 -CloseRun <issue-number>'
}
