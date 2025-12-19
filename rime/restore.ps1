<#
.SYNOPSIS
    Restores the most recent Rime (Weasel) configuration from a local backup.
#>

$ErrorActionPreference = "Stop"

# ==============================================================================
# 1. Define Paths
# ==============================================================================
Write-Host "Starting Rime (Weasel) configuration restore..." -ForegroundColor Cyan

# The 'rime' directory within this repository
$RepoRimeDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Weasel's user data directory on Windows
$WeaselUserDataDir = "$env:APPDATA\Rime"

# Define the temporary directory where backups are stored
$TempDir = Join-Path $env:TEMP "dotfiles-rime-installer"
$BackupDir = Join-Path $TempDir "backup"

Write-Host "Repository Rime Directory: $RepoRimeDir" -ForegroundColor Gray
Write-Host "Weasel User Data Directory: $WeaselUserDataDir" -ForegroundColor Gray
Write-Host "Backup Directory (in Temp): $BackupDir" -ForegroundColor Gray

# ==============================================================================
# 2. Find the Latest Backup
# ==============================================================================

if (-not (Test-Path $BackupDir)) {
    Write-Host "[ERROR] Backup directory not found at $BackupDir. Cannot restore." -ForegroundColor Red
    exit 1
}

$latestBackup = Get-ChildItem -Path $BackupDir | Where-Object { $_.PSIsContainer } | Sort-Object Name -Descending | Select-Object -First 1

if ($null -eq $latestBackup) {
    Write-Host "[ERROR] No backups found in $BackupDir. Cannot restore." -ForegroundColor Red
    exit 1
}

$LatestBackupPath = $latestBackup.FullName
Write-Host "[INFO] Found latest backup to restore: $LatestBackupPath" -ForegroundColor Yellow

# ==============================================================================
# 3. Confirm with User
# ==============================================================================

Write-Host "[WARNING] This action will completely overwrite your current Rime configuration at $WeaselUserDataDir." -ForegroundColor Yellow
$confirmation = Read-Host "Are you sure you want to proceed with the restore? (y/n)"

if ($confirmation -ne 'y') {
    Write-Host "Restore operation cancelled by user."
    exit
}

# ==============================================================================
# 4. Perform Restore
# ==============================================================================

Write-Host "[INFO] Starting restore process..."

# 1. Remove the existing configuration directory
if (Test-Path $WeaselUserDataDir) {
    Write-Host "[INFO] Removing current Rime configuration..."
    Remove-Item -Path $WeaselUserDataDir -Recurse -Force
}

# 2. Copy the backup to the original location
Write-Host "[INFO] Copying backup to $WeaselUserDataDir..."
Copy-Item -Path $LatestBackupPath -Destination $WeaselUserDataDir -Recurse -Force

Write-Host "[OK] Restore completed successfully." -ForegroundColor Green
Write-Host "Please redeploy your Rime input method to apply the restored configuration."
