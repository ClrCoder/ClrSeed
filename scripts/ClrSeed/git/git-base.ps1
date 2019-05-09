#!/usr/bin/pwsh

function Invoke-GitCommand {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, position = 0)]
        [string[]]$Arguments,
        [parameter(Mandatory = $false)]
        [string]$Cwd,
        [parameter(Mandatory = $false)]
        [string]$ErrorDetailsMessage
    )
    process {

        $env:LC_LOCAL = "C.UTF-8"
        if ($null -eq $IsWindows -or $IsWindows) {
            $curEncoding = [Console]::OutputEncoding
            $encodingName = $curEncoding.WebName
            if ($encodingName -ne "utf-8") {
                chcp.com 65001 | Out-Null
            }
        }

        try {
            if ($Cwd) {
                Push-Location $Cwd
            }

            $allOutput = git $Arguments 2>&1
            $stderr = $allOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }
            $stdout = $allOutput | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }

            $stdout

            if ($LASTEXITCODE -ne 0) {
                $errorMessage = $stderr | Out-String
                $exception = New-Object System.Management.Automation.RemoteException $errorMessage
                $errorID = 'NativeCommandError'
                $category = [Management.Automation.ErrorCategory]::ResourceUnavailable
                $target = "git"
                $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID, $category, $target
                if ($ErrorDetailsMessage) {
                    $errorRecord.ErrorDetails = New-Object Management.Automation.ErrorDetails $ErrorDetailsMessage
                }
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
        finally {
            if ($Cwd) {
                Pop-Location | Out-Null
            }
        }
    }
}
