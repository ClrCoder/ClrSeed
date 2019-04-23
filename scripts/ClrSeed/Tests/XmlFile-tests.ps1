Remove-Module ClrSeed -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot/../ClrSeed.psm1


$tst = Get-XmlFile -Path $PSScriptRoot/TestFiles/ClrSeed.csproj
Set-XmlFile $tst.Xml -Path $PSScriptRoot/TestFiles/ClrSeed.csproj.tmp -Encoding $tst.Encoding

$tst = Get-XmlFile -Path $PSScriptRoot/TestFiles/some.xml
Set-XmlFile $tst.Xml -Path $PSScriptRoot/TestFiles/some.xml.tmp -Encoding $tst.Encoding
