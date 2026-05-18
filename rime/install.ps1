<#
.SYNOPSIS
    Install and configure Rime (Weasel) from the chezmoi-managed upstream checkout.
#>

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)
$RepoRimeDir = Join-Path $RepoRoot "rime"
$WeaselUserDataDir = "$env:APPDATA\Rime"
$OneDriveSyncDir = "$env:OneDrive\Backups\rime"
$TempDir = Join-Path $env:TEMP "dotfiles-rime-installer"
$BackupDir = Join-Path $TempDir "backup"
$UpstreamDir = "$env:USERPROFILE\.local\share\rime-frost"

if (-not (Test-Path $UpstreamDir)) {
    throw "Missing upstream directory: $UpstreamDir"
}

if (Test-Path $WeaselUserDataDir) {
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $CurrentBackupPath = Join-Path $BackupDir "Rime_backup_$timestamp"
    robocopy $WeaselUserDataDir $CurrentBackupPath /E /B /R:1 /W:1 | Out-Null
}

if (-not (Test-Path $WeaselUserDataDir)) {
    New-Item -ItemType Directory -Path $WeaselUserDataDir -Force | Out-Null
}

Copy-Item -Path "$UpstreamDir\*" -Destination $WeaselUserDataDir -Recurse -Force
Copy-Item -Path (Join-Path $RepoRimeDir "custom\*") -Destination $WeaselUserDataDir -Recurse -Force
Copy-Item -Path (Join-Path $RepoRimeDir "opencc\*") -Destination (Join-Path $WeaselUserDataDir "opencc") -Recurse -Force

$DestSyncDir = Join-Path $WeaselUserDataDir "sync"
if (Test-Path $OneDriveSyncDir) {
    if (Test-Path $DestSyncDir) {
        Remove-Item $DestSyncDir -Recurse -Force
    }
    New-Item -ItemType SymbolicLink -Path $DestSyncDir -Target $OneDriveSyncDir -Force | Out-Null
}
