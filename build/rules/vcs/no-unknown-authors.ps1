#!/usr/bin/pwsh
using namespace System.Collections.Generic

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/../../.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

. ("$repoRoot/scripts/ClrSeed/git/git-base.ps1")
. ("$repoRoot/scripts/ClrSeed/hg/hg-base.ps1")

function Select-HgCommitAuthor {
    $curChangeset = @{ }
    $input | % {
        if ($_[0] -eq [char]0) {
            if ($curChangeset.Keys.Count -ne 0) {
                $curChangeset
                $curChangeset = @{ }
            }
            $idParts = $_.Split(":")
            $curChangeset.LocalId = $idParts[0].Substring(1, $idParts[0].Length - 1)
            $curChangeset.Hash = $idParts[1]
        }
        else {
            $curChangeset.Author = $_
        }
    }
    if ($curChangeset.Keys.Count -ne 0) {
        $curChangeset
    }
}

function Select-GitCommitAuthor {
    $curChangeset = @{ }
    $input | % {
        if ($_[0] -eq [char]0) {
            if ($curChangeset.Keys.Count -ne 0) {
                $curChangeset
                $curChangeset = @{ }
            }
            $curChangeset.Hash = $_.Substring(1, $_.Length - 1)
        }
        else {
            $curChangeset.Author = $_
        }
    }
    if ($curChangeset.Keys.Count -ne 0) {
        $curChangeset
    }
}

try {
    # For Debug
    #$repoRoot = "C:\Projects\ClrSeed\h1"

    [HashSet[string]]$knownAuthors = @(
        "Dmitriy Ivanov <dmitriy.se@gmail.com>"
        "azure-pipelines[bot] <azure-pipelines[bot]@users.noreply.github.com>"
    )

    [HashSet[string]]$foundAuthors = @()

    if (Test-Path "$repoRoot/.hg" -Type Container) {
        $foundAuthors = (Invoke-HgCommand -Arguments "log", "--rev", "ancestors(.)", "--template", "\0{rev}:{node}\n{author}\n" -Cwd $repoRoot | Select-HgCommitAuthor).Author
    }
    elseif (Test-Path "$repoRoot/.git") {
        $foundAuthors = (Invoke-GitCommand -Arguments "log", "--pretty=format:%x00%H%n%an <%ae>" -Cwd $repoRoot | Select-GitCommitAuthor).Author
    }
    else {
        throw "Unknown repository type."
    }

    $foundAuthors.ExceptWith($knownAuthors)
    $unknownAuthors = $foundAuthors

    if ($unknownAuthors.Count -gt 0) {
        Write-Host "Found unknown authors:" -ForegroundColor Yellow
        foreach ($author in $unknownAuthors) {
            Write-Host $author
        }
        throw "Found unknown authors"
    }
}
catch {
    throw
}
