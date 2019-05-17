#!/usr/bin/pwsh
param (
    [switch]$ForceFix
)

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot"
$scriptsRoot = "$repoRoot/scripts"
$rulesRoot = "$repoRoot/build/rules"
# ---------------------------------------------------------------------

try{
    # Checking environment
    &"$repoRoot/build/environment-check.ps1"

    if ($ForceFix){
        $fixMode = $true
    }else{

        $changedFiles = &"$scriptsRoot/repo-search.ps1" ** -Status am?
        if ($changedFiles){
            Write-Host "------------------UNCOMMITTED CHANGES----------------------------" -ForegroundColor Yellow
            $changedFiles | Out-Host
            Write-Host "-----------------------------------------------------------------" -ForegroundColor Yellow
            Write-Host "WARNING: Automatic fixes are disabled due to uncommitted changes." -ForegroundColor Yellow
            Write-Host "-----------------------------------------------------------------" -ForegroundColor Yellow
        }
        else{
            $fixMode = $true
        }
    }

    Write-Host
    Write-Host "Checking commits history rules" -ForegroundColor Green
    &"$rulesRoot/vcs/no-relative-issue-refs.ps1"
    &"$rulesRoot/vcs/no-unknown-authors.ps1"

    Write-Host
    Write-Host "Checking and applying '*.sln' files rules" -ForegroundColor Green
    &"$rulesRoot/dotnet/sln-no-anycpu-configurations.ps1" -Fix:$fixMode
    &"$rulesRoot/dotnet/sln-vs-version.ps1" -Fix:$fixMode

    Write-Host
    Write-Host "Checking & applying 'eclint' rules" -ForegroundColor Green
    &"$rulesRoot/text/eclint.ps1" -Fix:$fixMode

    Write-Host

    # Writing finall status of this script
    $changedFiles = &"$scriptsRoot/repo-search.ps1" ** -Status amd?
    if ($changedFiles) {
        Write-Host "------------------YOU ARE NOT READY TO PUSH----------------------" -ForegroundColor Yellow
        $changedFiles | Out-Host
        Write-Host "-----------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host "     You have uncommited changes in your working directory."       -ForegroundColor Yellow
        Write-Host "-----------------------------------------------------------------" -ForegroundColor Yellow
        return
    }

    # Budling Release
    Write-Host
    &"$repoRoot/build/build.ps1" -Mode PrePush -Configuration Release -Platform x64
    # TODO: Put here assemble of final artifacts (that can depends on multiple )

    # Building in Debug
    Write-Host
    &"$repoRoot/build/build.ps1" -Mode PrePush -Configuration Debug -Platform x64

    Write-Host
    Write-Host "=================================================================" -ForegroundColor Green
    Write-Host "            Congratulation! You are ready to PUSH!"                -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Green
}
catch{
    throw
}
