$ErrorActionPreference = 'Stop'

$targetDir = Join-Path $HOME "Documents\PowerShell"
$targetScript = Join-Path $targetDir "powershell-cli-tools.ps1"
$backupProfile = "$PROFILE.bak"

try {
    # Backup profile if exists
    if (Test-Path $PROFILE) {
        Copy-Item $PROFILE $backupProfile -Force
    }

    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

    $profileDir = Split-Path $PROFILE
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

    Copy-Item ".\scripts\powershell-cli-tools.ps1" $targetScript -Force

    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    }

    $profileLine = ". `"$targetScript`""

    if (-not (Select-String -Path $PROFILE -Pattern ([regex]::Escape($profileLine)) -Quiet)) {
        Add-Content -Path $PROFILE -Value "`n# === PowerShell CLI Tools ==="
        Add-Content -Path $PROFILE -Value $profileLine
    }

    # Success → remove backup
    if (Test-Path $backupProfile) {
        Remove-Item $backupProfile -Force
    }

    Write-Host "Installed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Installation failed. Rolling back..." -ForegroundColor Red

    if (Test-Path $backupProfile) {
        Copy-Item $backupProfile $PROFILE -Force
        Remove-Item $backupProfile -Force
    }

    if (Test-Path $targetScript) {
        Remove-Item $targetScript -Force
    }

    Write-Host "Rollback completed." -ForegroundColor Yellow
    Write-Host $_
}
