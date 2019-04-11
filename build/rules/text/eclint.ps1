#!/usr/bin/pwsh

param(
    [switch]$Fix
)

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/../../.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

try{
    &"$scriptsRoot/ensure-deps.ps1"

    Push-Location $repoRoot/scripts

    try {
        if ($Fix){
            # Fix last line and trim spaces
            npm run eclint-fix
            if ($LASTEXITCODE -ne 0){
                throw "Editor config text rules fixing failed"
            }
        }

        # Checking everything else
        npm run eclint-check
        if ($LASTEXITCODE -ne 0){
            throw "Editor config text rules check failed"
        }

    }
    finally {
        Pop-Location > $null
    }
}
catch{
    throw
}
