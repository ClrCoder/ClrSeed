@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'ClrSeed.psm1'

    # Version number of this module.
    ModuleVersion     = '0.0.0'

    # ID used to uniquely identify this module
    GUID              = '41249E74-8A4B-4D2D-8E1B-61B2F37E276A'

    # Author of this module
    Author            = 'ClrCoder community'

    # Copyright statement for this module
    Copyright         = '(c) 2019 ClrCoder community'

    # Description of the functionality provided by this module
    Description       = 'ClrSeed repository services module'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
        'Compare-ByteArrays',
        'Get-XmlFile',
        'Set-XmlFile'
    )

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport   = @()

    RequiredModules   = @(
    )
    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    # This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('lpm')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/ClrCoder/ClrSeed/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/ClrCoder/ClrSeed'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/ClrCoder/ClrSeed/blob/master/SEED-CHANGELOG.md'
        }
    }
}
