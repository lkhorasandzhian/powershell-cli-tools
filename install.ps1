$ErrorActionPreference = 'Stop'

$moduleName = 'PowerShellCliTools'
$sourceModuleDir = Join-Path $PSScriptRoot $moduleName
$targetModulesDir = Join-Path $HOME 'Documents\PowerShell\Modules'
$targetModuleDir = Join-Path $targetModulesDir $moduleName
$moduleManifest = Join-Path $targetModuleDir "$moduleName.psd1"
$installId = [guid]::NewGuid().ToString('N')
$backupModuleDir = Join-Path $targetModulesDir "$moduleName.backup-$installId"
$stagingModuleDir = Join-Path $targetModulesDir "$moduleName.installing-$installId"
$backupProfile = $null

$profileChanged = $false
$keepProfileBackup = $false
$existingModuleBackedUp = $false
$newModuleActivated = $false
$installSucceeded = $false
$installMutex = [System.Threading.Mutex]::new($false, 'Global\PowerShellCliTools.Install')
$lockAcquired = $false

try {
    try {
        $lockAcquired = $installMutex.WaitOne(0)
    }
    catch [System.Threading.AbandonedMutexException] {
        $lockAcquired = $true
    }
    if (-not $lockAcquired) {
        throw "An installation of '$moduleName' is already running."
    }

    Write-Host "Installing module '$moduleName'..." -ForegroundColor Cyan
    Write-Host "  Source: $sourceModuleDir" -ForegroundColor DarkGray
    Write-Host "  Target: $targetModuleDir" -ForegroundColor DarkGray
    Write-Host "  Profile: $PROFILE" -ForegroundColor DarkGray

    if (-not (Test-Path -LiteralPath $sourceModuleDir -PathType Container)) {
        throw "Module source directory not found: $sourceModuleDir"
    }

    Write-Host 'Preparing install directories...' -ForegroundColor Cyan

    New-Item -ItemType Directory -Path $targetModulesDir -Force | Out-Null

    $profileDir = Split-Path -LiteralPath $PROFILE
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

    $profileExisted = Test-Path -LiteralPath $PROFILE
    if ($profileExisted) {
        Write-Host 'Backing up existing PowerShell profile...' -ForegroundColor Cyan
        $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
        $backupPrefix = "$PROFILE.$timestamp"
        $candidate = "$backupPrefix.bak"
        $copyNumber = 2
        while (Test-Path -LiteralPath $candidate) {
            $candidate = "$backupPrefix.$copyNumber.bak"
            $copyNumber++
        }
        [System.IO.File]::Copy($PROFILE, $candidate)
        $backupProfile = $candidate
    }
    else {
        Write-Host 'PowerShell profile does not exist yet. A new one will be created.' -ForegroundColor Cyan
    }

    Write-Host "Copying module files to staging: $stagingModuleDir" -ForegroundColor Cyan
    Copy-Item -LiteralPath $sourceModuleDir -Destination $stagingModuleDir -Recurse -Force
    Test-ModuleManifest -Path (Join-Path $stagingModuleDir "$moduleName.psd1") | Out-Null

    if (Test-Path -LiteralPath $targetModuleDir) {
        Write-Host "Existing module found. Moving it to backup: $backupModuleDir" -ForegroundColor Cyan
        Move-Item -LiteralPath $targetModuleDir -Destination $backupModuleDir
        $existingModuleBackedUp = $true
    }

    Write-Host 'Activating new module version...' -ForegroundColor Cyan
    Move-Item -LiteralPath $stagingModuleDir -Destination $targetModuleDir
    $newModuleActivated = $true

    if (-not $profileExisted) {
        New-Item -ItemType File -Path $PROFILE | Out-Null
        $profileChanged = $true
    }

    $profileLine = "Import-Module `"$moduleManifest`" -Force"
    $profileMarker = '# === PowerShell CLI Tools ==='

    if (-not (Select-String -LiteralPath $PROFILE -Pattern $profileLine -SimpleMatch -Quiet)) {
        Write-Host 'Updating PowerShell profile to auto-import the module...' -ForegroundColor Cyan
        $profileChanged = $true
        Add-Content -LiteralPath $PROFILE -Value ""

        if (-not (Select-String -LiteralPath $PROFILE -Pattern $profileMarker -SimpleMatch -Quiet)) {
            Add-Content -LiteralPath $PROFILE -Value $profileMarker
        }

        Add-Content -LiteralPath $PROFILE -Value $profileLine
    }
    else {
        Write-Host 'PowerShell profile already contains the module import line.' -ForegroundColor Cyan
    }

    $installSucceeded = $true
}
catch {
    if ($lockAcquired) {
        Write-Host 'Installation failed. Rolling back...' -ForegroundColor Red

        try {
            if ($profileChanged) {
                if ($profileExisted) {
                    Copy-Item -LiteralPath $backupProfile -Destination $PROFILE -Force
                }
                else {
                    Remove-Item -LiteralPath $PROFILE -Force
                }
            }
        }
        catch {
            $keepProfileBackup = $true
            Write-Warning "Could not restore the profile. Backup path: '$backupProfile'. $_"
        }

        try {
            if ($newModuleActivated) {
                Remove-Item -LiteralPath $targetModuleDir -Recurse -Force
            }
            if ($existingModuleBackedUp) {
                Move-Item -LiteralPath $backupModuleDir -Destination $targetModuleDir
            }
        }
        catch {
            Write-Warning "Could not roll back the module installation. Backup directory: '$backupModuleDir'. $_"
        }
    }

    throw
}
finally {
    try {
        if ($lockAcquired) {
            $cleanupPaths = @($stagingModuleDir)
            if ($installSucceeded -and $existingModuleBackedUp) {
                $cleanupPaths += $backupModuleDir
            }
            if ($backupProfile -and -not $keepProfileBackup) {
                $cleanupPaths += $backupProfile
            }

            foreach ($cleanupPath in $cleanupPaths) {
                try {
                    if (Test-Path -LiteralPath $cleanupPath) {
                        Remove-Item -LiteralPath $cleanupPath -Recurse -Force
                    }
                }
                catch {
                    Write-Warning "Could not remove '$cleanupPath'. $_"
                }
            }
        }
    }
    finally {
        if ($lockAcquired) {
            $installMutex.ReleaseMutex()
        }
        $installMutex.Dispose()
    }
}

Write-Host 'Installation completed successfully.' -ForegroundColor Green
Write-Host "  Module installed to: $targetModuleDir" -ForegroundColor DarkYellow
Write-Host "  Auto-import configured in: $PROFILE" -ForegroundColor DarkYellow
Write-Host "Start a new PowerShell session or run: Import-Module `"$moduleManifest`" -Force" -ForegroundColor Yellow
