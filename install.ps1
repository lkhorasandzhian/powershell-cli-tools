$ErrorActionPreference = 'Stop'

$moduleName = 'PowerShellCliTools'
$sourceModuleDir = Join-Path $PSScriptRoot $moduleName
$targetModulesDir = Join-Path $HOME 'Documents\PowerShell\Modules'
$targetModuleDir = Join-Path $targetModulesDir $moduleName
$moduleManifest = Join-Path $targetModuleDir "$moduleName.psd1"
$backupProfile = "$PROFILE.bak"
$backupModuleDir = Join-Path $targetModulesDir "$moduleName.backup"
$stagingModuleDir = Join-Path $targetModulesDir "$moduleName.installing"

$profileExisted = Test-Path $PROFILE
$targetModuleExisted = Test-Path $targetModuleDir

try {
    Write-Host "Installing module '$moduleName'..." -ForegroundColor Cyan
    Write-Host "  Source: $sourceModuleDir" -ForegroundColor DarkGray
    Write-Host "  Target: $targetModuleDir" -ForegroundColor DarkGray
    Write-Host "  Profile: $PROFILE" -ForegroundColor DarkGray

    if (-not (Test-Path $sourceModuleDir)) {
        throw "Module source directory not found: $sourceModuleDir"
    }

    Write-Host 'Preparing install directories...' -ForegroundColor Cyan

    if (Test-Path $backupProfile) {
        Remove-Item $backupProfile -Force
    }

    if (Test-Path $backupModuleDir) {
        Remove-Item $backupModuleDir -Recurse -Force
    }

    if (Test-Path $stagingModuleDir) {
        Remove-Item $stagingModuleDir -Recurse -Force
    }

    New-Item -ItemType Directory -Path $targetModulesDir -Force | Out-Null

    $profileDir = Split-Path $PROFILE
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

    if ($profileExisted) {
        Write-Host 'Backing up existing PowerShell profile...' -ForegroundColor Cyan
        Copy-Item $PROFILE $backupProfile -Force
    }
    else {
        Write-Host 'PowerShell profile does not exist yet. A new one will be created.' -ForegroundColor Cyan
    }

    Write-Host "Copying module files to staging: $stagingModuleDir" -ForegroundColor Cyan
    Copy-Item $sourceModuleDir $stagingModuleDir -Recurse -Force

    if ($targetModuleExisted) {
        Write-Host "Existing module found. Moving it to backup: $backupModuleDir" -ForegroundColor Cyan
        Move-Item $targetModuleDir $backupModuleDir -Force
    }

    Write-Host 'Activating new module version...' -ForegroundColor Cyan
    Move-Item $stagingModuleDir $targetModuleDir -Force

    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    }

    $profileLine = "Import-Module `"$moduleManifest`" -Force"
    $profileMarker = '# === PowerShell CLI Tools ==='

    if (-not (Select-String -Path $PROFILE -Pattern ([regex]::Escape($profileLine)) -Quiet)) {
        Write-Host 'Updating PowerShell profile to auto-import the module...' -ForegroundColor Cyan
        Add-Content -Path $PROFILE -Value ""

        if (-not (Select-String -Path $PROFILE -Pattern ([regex]::Escape($profileMarker)) -Quiet)) {
            Add-Content -Path $PROFILE -Value $profileMarker
        }

        Add-Content -Path $PROFILE -Value $profileLine
    }
    else {
        Write-Host 'PowerShell profile already contains the module import line.' -ForegroundColor Cyan
    }

    if (Test-Path $backupProfile) {
        Remove-Item $backupProfile -Force
    }

    if (Test-Path $backupModuleDir) {
        Remove-Item $backupModuleDir -Recurse -Force
    }

    Write-Host 'Installation completed successfully.' -ForegroundColor Green
    Write-Host "  Module installed to: $targetModuleDir" -ForegroundColor DarkYellow
    Write-Host "  Auto-import configured in: $PROFILE" -ForegroundColor DarkYellow
    Write-Host "Start a new PowerShell session or run: Import-Module `"$moduleManifest`" -Force" -ForegroundColor Yellow
}
catch {
    Write-Host 'Installation failed. Rolling back...' -ForegroundColor Red

    if (Test-Path $targetModuleDir) {
        Remove-Item $targetModuleDir -Recurse -Force
    }

    if (Test-Path $stagingModuleDir) {
        Remove-Item $stagingModuleDir -Recurse -Force
    }

    if (Test-Path $backupModuleDir) {
        Move-Item $backupModuleDir $targetModuleDir -Force
    }

    if (Test-Path $backupProfile) {
        Copy-Item $backupProfile $PROFILE -Force
        Remove-Item $backupProfile -Force
    }
    elseif (-not $profileExisted -and (Test-Path $PROFILE)) {
        Remove-Item $PROFILE -Force
    }

    Write-Host 'Rollback completed.' -ForegroundColor Yellow
    Write-Host $_
}
