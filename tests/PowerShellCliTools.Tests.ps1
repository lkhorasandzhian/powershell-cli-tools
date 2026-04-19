Describe 'PowerShellCliTools module' {
    $moduleManifest = Join-Path $PSScriptRoot '..\PowerShellCliTools\PowerShellCliTools.psd1'
    Import-Module $moduleManifest -Force

    It 'exports the approved-verb commands' {
        Get-Command Get-FileCount -ErrorAction Stop | Should Not BeNullOrEmpty
        Get-Command Get-LineCount -ErrorAction Stop | Should Not BeNullOrEmpty
        Get-Command Get-CodeStats -ErrorAction Stop | Should Not BeNullOrEmpty
        Get-Command Show-ColorTree -ErrorAction Stop | Should Not BeNullOrEmpty
    }

    It 'keeps the legacy aliases' {
        Get-Command file-counter -ErrorAction Stop | Should Not BeNullOrEmpty
        Get-Command line-counter -ErrorAction Stop | Should Not BeNullOrEmpty
        Get-Command super-counter -ErrorAction Stop | Should Not BeNullOrEmpty
        Get-Command tree-color -ErrorAction Stop | Should Not BeNullOrEmpty
        Get-Command la -ErrorAction Stop | Should Not BeNullOrEmpty
        Get-Command .. -ErrorAction Stop | Should Not BeNullOrEmpty
        Get-Command home -ErrorAction Stop | Should Not BeNullOrEmpty
        Get-Command repos -ErrorAction Stop | Should Not BeNullOrEmpty
    }
}
