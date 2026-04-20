@{
    RootModule = 'PowerShellCliTools.psm1'
    ModuleVersion = '1.0.0'
    GUID = '60f17574-7e74-4c6a-8135-0dc03c86c0c4'
    Author = 'Levon Khorasandzhian'
    CompanyName = 'Personal'
    Copyright = '(c) Levon Khorasandzhian. All rights reserved.'
    Description = 'Useful PowerShell CLI tools, counters, shortcuts, and colorful tree output.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Get-FileCount',
        'Get-LineCount',
        'Get-CodeStats',
        'Show-ColorTree',
        'Get-AllItems',
        'Set-ParentLocation',
        'Set-HomeLocation',
        'Set-ReposLocation'
    )
    AliasesToExport = @(
        'll',
        'la',
        '..',
        'home',
        'repos',
        'file-counter',
        'line-counter',
        'super-counter',
        'tree-color'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('PowerShell', 'CLI', 'Tools', 'Productivity')
            ProjectUri = 'https://github.com/lkhorasandzhian/powershell-cli-tools'
            LicenseUri = 'https://github.com/lkhorasandzhian/powershell-cli-tools/blob/main/LICENSE'
        }
    }
}
