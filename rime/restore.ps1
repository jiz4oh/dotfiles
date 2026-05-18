<#
.SYNOPSIS
    Restore the most recent Rime backup on Windows.
#>

$ErrorActionPreference = "Stop"

$WeaselUserDataDir = "$env:APPDATA\Rime"
$TempDir = Join-Path $env:TEMP "dotfiles-rime-installer"
$BackupDir = Join-Path $TempDir "backup"

if (-not (Test-Path $BackupDir)) {
    throw "Backup directory not found at $BackupDir"
}

$latestBackup = Get-ChildItem -Path $BackupDir | Where-Object { $_.PSIsContainer } | Sort-Object Name -Descending | Select-Object -First 1
if ($null -eq $latestBackup) {
    throw "No backups found in $BackupDir"
}

if (Test-Path $WeaselUserDataDir) {
    Remove-Item -Path $WeaselUserDataDir -Recurse -Force
}

Copy-Item -Path $latestBackup.FullName -Destination $WeaselUserDataDir -Recurse -Force
