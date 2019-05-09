#!/usr/bin/pwsh

# -------- These variables are controlled by repo-pathes tool ---------
$repoRoot = Resolve-Path "$PSScriptRoot/../../.."
$scriptsRoot = "$repoRoot/scripts"
# ---------------------------------------------------------------------

. ("$repoRoot/scripts/ClrSeed/git/git-base.ps1")
. ("$repoRoot/scripts/ClrSeed/hg/hg-base.ps1")

function Select-HgCommitMessages {
    $curChangeset = @{}
    $input | % {
        if ($_[0] -eq [char]0) {
            if ($curChangeset.Keys.Count -ne 0) {
                $curChangeset
                $curChangeset = @{}
            }
            $idParts = $_.Split(":")
            $curChangeset.LocalId = $idParts[0].Substring(1, $idParts[0].Length - 1)
            $curChangeset.Hash = $idParts[1]
        }
        else {
            if (!$curChangeset.ContainsKey("Message")) {
                $curChangeset.Message = $_
            }
            else {
                $curChangeset.Message += [Environment]::NewLine + $_
            }
        }
    }
    if ($curChangeset.Keys.Count -ne 0) {
        $curChangeset
    }
}

function Select-GitCommitMessages {
    $curChangeset = @{}
    $input | % {
        if ($_[0] -eq [char]0) {
            if ($curChangeset.Keys.Count -ne 0) {
                $curChangeset
                $curChangeset = @{}
            }
            $curChangeset.Hash = $_.Substring(1, $_.Length - 1)
        }
        else {
            if (!$curChangeset.ContainsKey("Message")) {
                $curChangeset.Message = $_
            }
            else {
                $curChangeset.Message += [Environment]::NewLine + $_
            }
        }
    }
    if ($curChangeset.Keys.Count -ne 0) {
        $curChangeset
    }
}

try {

    if (Test-Path "$repoRoot/.hg" -Type Container) {
        $changeSets = Invoke-HgCommand -Arguments "log", "--template", "\0{rev}:{node}\n{desc}\n" -Cwd $repoRoot | Select-HgCommitMessages
    }
    elseif (Test-Path "$repoRoot/.git" -Type Container) {
        $changeSets = Invoke-GitCommand -Arguments "log", "--pretty=format:%x00%H%n%B" -Cwd $repoRoot | Select-GitCommitMessages
    }
    else {
        throw "Unknown repository type."
    }

    foreach ($commit in $changeSets) {
        if ($commit.Message -match " \#\d+") {
            Write-Warning "Changeset with error: $($commit.Message)"
            throw "All '#<number>' references should be prefixed by a repository name. ChangeSet Hash=$($commit.Hash)"
        }
    }
}
catch {
    throw
}
