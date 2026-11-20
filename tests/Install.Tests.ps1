Describe 'PowerShellCliTools installer' {
    BeforeAll {
        $installer = Join-Path $PSScriptRoot '..\install.ps1'
        $pwsh = (Get-Process -Id $PID).Path
        $runner = Join-Path $TestDrive 'Run-Installer.ps1'

        @'
param(
    [string]$Installer,
    [string]$Sandbox,
    [switch]$FailProfileUpdate,
    [switch]$FailProfileRestore
)

$ErrorActionPreference = 'Stop'
$PROFILE = Microsoft.PowerShell.Management\Join-Path $Sandbox 'profile.ps1'

function Join-Path {
    param([string]$Path, [string]$ChildPath)

    if ($ChildPath -eq 'Documents\PowerShell\Modules') {
        return (Microsoft.PowerShell.Management\Join-Path $Sandbox 'Modules')
    }
    Microsoft.PowerShell.Management\Join-Path $Path $ChildPath
}

function Get-Date {
    param([string]$Format)
    [datetime]::new(2026, 4, 20, 14, 35, 8).ToString($Format)
}

function Add-Content {
    param([string]$LiteralPath, [string]$Value)

    if ($FailProfileUpdate -and $Value -like 'Import-Module*') {
        throw 'Test failure during profile update'
    }
    Microsoft.PowerShell.Management\Add-Content @PSBoundParameters
}

function Copy-Item {
    param([string]$LiteralPath, [string]$Destination, [switch]$Recurse, [switch]$Force)

    if ($FailProfileRestore -and $LiteralPath -like '*.bak') {
        throw 'Test failure during profile restore'
    }
    Microsoft.PowerShell.Management\Copy-Item @PSBoundParameters
}

& $Installer
'@ | Set-Content -LiteralPath $runner

        function Invoke-TestInstaller {
            param([string[]]$InstallerArguments)

            $PSNativeCommandUseErrorActionPreference = $false
            $output = & $pwsh -NoProfile -NonInteractive -File $runner -Installer $installer -Sandbox $caseDir @InstallerArguments 2>&1
            [pscustomobject]@{
                ExitCode = $LASTEXITCODE
                Output   = $output -join [Environment]::NewLine
            }
        }
    }

    BeforeEach {
        $caseDir = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        $caseProfile = Join-Path $caseDir 'profile.ps1'
        $moduleDir = Join-Path $caseDir 'Modules\PowerShellCliTools'
        New-Item -ItemType Directory -Path $caseDir | Out-Null
        Set-Content -LiteralPath $caseProfile -Value '# My PowerShell settings' -NoNewline
        Set-Content -LiteralPath "$caseProfile.bak" -Value '# My backup' -NoNewline
    }

    It 'preserves a user backup and cleans up its own backup on success' {
        $result = Invoke-TestInstaller

        $result.ExitCode | Should -Be 0 -Because $result.Output
        Get-Content -LiteralPath "$caseProfile.bak" -Raw | Should -Be '# My backup'
        Get-Content -LiteralPath $caseProfile -Raw | Should -Match '# My PowerShell settings'
        Get-Content -LiteralPath $caseProfile -Raw | Should -Match 'Import-Module'
        Join-Path $moduleDir 'PowerShellCliTools.psd1' | Should -Exist
        @(Get-ChildItem -LiteralPath $caseDir -Filter '*.bak').Count | Should -Be 1
    }

    It 'restores the profile and the previous module and exits nonzero when the update fails' {
        New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $moduleDir 'previous-version.txt') -Value 'previous'

        $result = Invoke-TestInstaller -InstallerArguments '-FailProfileUpdate'

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'Test failure during profile update'
        Get-Content -LiteralPath $caseProfile -Raw | Should -Be '# My PowerShell settings'
        Get-Content -LiteralPath "$caseProfile.bak" -Raw | Should -Be '# My backup'
        Join-Path $moduleDir 'previous-version.txt' | Should -Exist
        Join-Path $moduleDir 'PowerShellCliTools.psd1' | Should -Not -Exist
        @(Get-ChildItem -LiteralPath $caseDir -Filter '*.bak').Count | Should -Be 1
    }

    It 'keeps its dated backup for recovery when restore fails and the first name was taken' {
        $existingDatedBackup = "$caseProfile.2026-04-20_14-35-08.bak"
        Set-Content -LiteralPath $existingDatedBackup -Value '# Earlier backup' -NoNewline

        $result = Invoke-TestInstaller -InstallerArguments '-FailProfileUpdate', '-FailProfileRestore'

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'Test failure during profile restore'
        Get-Content -LiteralPath "$caseProfile.2026-04-20_14-35-08.2.bak" -Raw |
            Should -Be '# My PowerShell settings'
        Get-Content -LiteralPath $existingDatedBackup -Raw | Should -Be '# Earlier backup'
        Get-Content -LiteralPath "$caseProfile.bak" -Raw | Should -Be '# My backup'
        $moduleDir | Should -Not -Exist
    }
}
