#!/usr/bin/pwsh

function Invoke-HgCommand {
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
        $curEncoding = [Console]::OutputEncoding

        $encodingName = $curEncoding.WebName

        $Arguments += @("--encoding", $encodingName)
        if ($Cwd) {
            $Arguments += @("--cwd", $Cwd)
        }

        $allOutput = hg $Arguments 2>&1
        $stderr = $allOutput | ? { $_ -is [System.Management.Automation.ErrorRecord] }
        $stdout = $allOutput | ? { $_ -isnot [System.Management.Automation.ErrorRecord] }

        $stdout

        if ($LASTEXITCODE -ne 0) {
            $errorMessage = $stderr | Out-String
            $exception = New-Object System.Management.Automation.RemoteException $errorMessage
            $errorID = 'NativeCommandError'
            $category = [Management.Automation.ErrorCategory]::ResourceUnavailable
            $target = "hg"
            $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID, $category, $target
            if ($ErrorDetailsMessage) {
                $errorRecord.ErrorDetails = New-Object Management.Automation.ErrorDetails $ErrorDetailsMessage
            }
            elseif ($errorMessage.StartsWith("abort: no repository found")) {
                $errorRecord.ErrorDetails = New-Object Management.Automation.ErrorDetails "Hg repository workdir has not been found"
            }
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}
