. ("$PSScriptRoot/git/git-base.ps1")
. ("$PSScriptRoot/hg/hg-base.ps1")

$utf8NoBom = New-Object System.Text.UTF8Encoding $false

Add-Type -Language CSharp @"
namespace Shame
{
    public static class DotNet
    {
        public static bool CompareBinary(byte[] a1, byte[] a2)
        {
            if (a1.Length == a2.Length)
            {
                for(int i = 0; i < a1.Length; i++)
                {
                    if (a1[i] != a2[i])
                    {
                        return false;
                    }
                }
                return true;
            }
            return false;
        }
    }
}
"@;

function Compare-ByteArrays {
    param(
        $a1,
        $a2
    )
    [Shame.DotNet]::CompareBinary($originalContent, $buf)
}
function Get-XmlFile {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Path
    )

    $textReader = new-object System.IO.StreamReader $Path, $utf8NoBom, $true
    try {
        $textReader.Peek()
        $currentEncoding = $textReader.CurrentEncoding
        $xml = New-Object System.Xml.XmlDocument
        $xml.PreserveWhitespace = $true
        $xml.Load($textReader)
    }
    finally {
        $textReader.Dispose()
    }
    [PSCustomObject]@{
        Xml      = $xml
        Encoding = $currentEncoding
    }
}

function Set-XmlFile {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        $Xml,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [System.Text.Encoding]$Encoding)

    $outputFileExist = Test-Path $Path -PathType Leaf

    if (!$Encoding) {
        if ($outputFileExist) {
            $textReader = new-object System.IO.StreamReader $Path
            $Encoding = $textReader.CurrentEncoding
            $textReader.Dispose()
        }
        else {
            $Encoding = $utf8NoBom
        }
    }

    if ($outputFileExist) {
        $originalContent = [System.IO.File]::ReadAllBytes($Path)
    }
    else {
        $originalContent = [System.Byte[]]::CreateInstance([System.Byte], 0)
    }
    $memStream = New-Object System.IO.MemoryStream $originalContent.Length
    $textWriter = New-Object System.IO.StreamWriter $memStream, $Encoding
    $xmlWriterSettings = New-Object System.Xml.XmlWriterSettings
    $xmlWriterSettings.OmitXmlDeclaration = $Xml.FirstChild.NodeType -ne [System.Xml.XmlNodeType]::XmlDeclaration
    $xmlWriter = [System.Xml.XmlWriter]::Create($textWriter, $xmlWriterSettings)
    $Xml.Save($xmlWriter)
    $buf = $memStream.GetBuffer()
    $requreOverwrite = $false
    if (Compare-ByteArrays $originalContent, $buf) {
        # Do nothing, data is equals!
        # Write-Host "no any changes required" # Just for test
    }
    else {
        $requreOverwrite = $true
    }

    if ($requreOverwrite) {
        [System.IO.File]::WriteAllBytes($Path, $memStream.ToArray())
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'Compare-ByteArrays',
        'Get-XmlFile',
        'Set-XmlFile',
        'Invoke-GitCommand',
        'Invoke-HgCommand'
    )

    Variable = @(
    )
}

Export-ModuleMember @exportModuleMemberParams
