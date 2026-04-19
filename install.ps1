$ErrorActionPreference = 'Stop'

$moduleName = 'PowerShellCliTools'
$sourceModuleDir = Join-Path $PSScriptRoot $moduleName
$targetModulesDir = Join-Path $HOME 'Documents\PowerShell\Modules'
$targetModuleDir = Join-Path $targetModulesDir $moduleName
$moduleManifest = Join-Path $targetModuleDir "$moduleName.psd1"
$backupProfile = "$PROFILE.bak"

try {
    if (Test-Path $PROFILE) {
        Copy-Item $PROFILE $backupProfile -Force
    }

    New-Item -ItemType Directory -Path $targetModulesDir -Force | Out-Null

    $profileDir = Split-Path $PROFILE
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

    if (Test-Path $targetModuleDir) {
        Remove-Item $targetModuleDir -Recurse -Force
    }

    Copy-Item $sourceModuleDir $targetModuleDir -Recurse -Force

    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    }

    $profileLine = "Import-Module `"$moduleManifest`" -Force"

    if (-not (Select-String -Path $PROFILE -Pattern ([regex]::Escape($profileLine)) -Quiet)) {
        Add-Content -Path $PROFILE -Value "`n# === PowerShell CLI Tools ==="
        Add-Content -Path $PROFILE -Value $profileLine
    }

    if (Test-Path $backupProfile) {
        Remove-Item $backupProfile -Force
    }

    Write-Host 'Installed successfully!' -ForegroundColor Green
}
catch {
    Write-Host 'Installation failed. Rolling back...' -ForegroundColor Red

    if (Test-Path $backupProfile) {
        Copy-Item $backupProfile $PROFILE -Force
        Remove-Item $backupProfile -Force
    }

    if (Test-Path $targetModuleDir) {
        Remove-Item $targetModuleDir -Recurse -Force
    }

    Write-Host 'Rollback completed.' -ForegroundColor Yellow
    Write-Host $_
}
