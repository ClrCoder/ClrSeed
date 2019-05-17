#!/usr/bin/pwsh

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/../.."
$rulesRoot = "$repoRoot/build/rules"
# ---------------------------------------------------------------------

try{
    Write-Host
    Write-Host "Checking commits history rules" -ForegroundColor Green
    &"$rulesRoot/vcs/no-relative-issue-refs.ps1"
    &"$rulesRoot/vcs/no-unknown-authors.ps1"

    Write-Host
    Write-Host "Checking and applying '*.sln' files rules" -ForegroundColor Green
    &"$rulesRoot/dotnet/sln-no-anycpu-configurations.ps1"
    &"$rulesRoot/dotnet/sln-vs-version.ps1"

    Write-Host
    Write-Host "Checking & applying 'eclint' rules" -ForegroundColor Green
    &"$rulesRoot/text/eclint.ps1"
}
catch{
    throw
}
