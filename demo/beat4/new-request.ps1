<#
.SYNOPSIS
  Stage 1: create the Modernization Request issue that starts the Beat 4 demo.

.DESCRIPTION
  Creates an issue in YOUR fork from demo\beat4\modernization-request.md. Its first line is
  /modernize-plan, which triggers the planner agent. Then watch the plan pull request appear.

    .\demo\beat4\new-request.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$Upstream = 'Azure-Samples/java-migration-copilot-samples'

$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) { throw 'Run this script from inside the cloned fork.' }
Set-Location $repoRoot

$originUrl = git remote get-url origin
if ($originUrl -notmatch 'github\.com[:/](?<owner>[^/]+)/(?<name>[^/]+?)(\.git)?$') { throw "Cannot read the GitHub repository from origin: $originUrl" }
$target = "$($Matches.owner)/$($Matches.name)"
if ($target -eq $Upstream) { throw "origin points at the upstream repository $Upstream. Use your fork." }

$body = Get-Content demo\beat4\modernization-request.md -Raw
$url = gh issue create --repo $target `
  --title 'Modernize Asset Manager to Java 21 and Spring Boot 3.5' `
  --label modernization-request `
  --body $body
if ($LASTEXITCODE -ne 0 -or -not $url) { throw 'Creating the Modernization Request failed. Run .\demo\beat4\setup.ps1 -CheckOnly and fix any MANUAL row.' }

Write-Host ''
Write-Host "Modernization Request created in ${target}:" -ForegroundColor Green
Write-Host "  $url"
Write-Host ''
Write-Host 'Watch the planner agent (takes a few minutes):'
Write-Host '  gh run list --workflow modernize-planner.lock.yml --limit 3'
Write-Host '  gh pr list --search "[modernization-plan] in:title"'
