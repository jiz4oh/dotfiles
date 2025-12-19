<#
.SYNOPSIS
    Installs and configures Rime (Weasel) on Windows, including the rime-frost theme.
    This script is idempotent and can be run multiple times safely.
#>

$ErrorActionPreference = "Stop"

# ==============================================================================
# 1. Define Paths and Parameters
# ==============================================================================
Write-Host "Starting Rime (Weasel) configuration..." -ForegroundColor Cyan

# Source: The 'rime' directory within this repository
$RepoRimeDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Destination: Weasel's user data directory on Windows
$WeaselUserDataDir = "$env:APPDATA\Rime"

# Sync source: The user's dictionary backup location in OneDrive
$OneDriveSyncDir = "$env:OneDrive\Backups\rime"

# Define a temporary directory for installer data (clones, backups)
$TempDir = Join-Path $env:TEMP "dotfiles-rime-installer"
if (-not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
}

# Backup directory in temp
$BackupDir = Join-Path $TempDir "backup"

# rime-frost repository details
$FrostRepoUrl = "https://github.com/gaboolic/rime-frost"
$FrostLocalDir = Join-Path $TempDir "rime-frost"
$UpstreamVersionFile = Join-Path $RepoRimeDir "upstream_version"
$FrostVersion = (Get-Content $UpstreamVersionFile -Raw).Trim()

Write-Host "Repository Rime Directory: $RepoRimeDir" -ForegroundColor Gray
Write-Host "Weasel User Data Directory: $WeaselUserDataDir" -ForegroundColor Gray
Write-Host "Temp Data Directory: $TempDir" -ForegroundColor Gray
Write-Host "OneDrive Sync Directory: $OneDriveSyncDir" -ForegroundColor Gray
Write-Host "rime-frost version to use: $FrostVersion" -ForegroundColor Gray


# ==============================================================================
# 2. Backup Existing Configuration
# ==============================================================================
if (Test-Path $WeaselUserDataDir) {
    # Ensure backup directory exists
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $CurrentBackupPath = Join-Path $BackupDir "Rime_backup_$timestamp"
    
    Write-Host "[INFO] Backing up existing Rime configuration to $CurrentBackupPath" -ForegroundColor Cyan
    # Use robocopy to handle files locked by the running Weasel process.
    # /E -> copy subdirectories, including empty ones.
    # /B -> copy files in Backup mode, which can copy files in use.
    # /R:1 -> retry once on error. /W:1 -> wait 1 second between retries.
    # robocopy's output can be verbose, so we pipe it to Out-Null unless it fails.
    $robocopyResult = robocopy $WeaselUserDataDir $CurrentBackupPath /E /B /R:1 /W:1
    if ($LASTEXITCODE -ge 4) {
        Write-Host "[ERROR] Robocopy failed with exit code $LASTEXITCODE. Backup may be incomplete." -ForegroundColor Red
        Write-Host "Please ensure you have adequate permissions (try running as Administrator)."
        # Optional: uncomment to see the full log
        # Write-Host $robocopyResult
    } else {
        Write-Host "[OK] Backup completed successfully." -ForegroundColor Green
    }
} else {
    Write-Host "[INFO] No existing Rime configuration found to back up." -ForegroundColor Yellow
}


# ==============================================================================
# 3. Download or Update rime-frost (Idempotent)
# ==============================================================================
Write-Host "[INFO] Checking rime-frost repository..."
if (-not (Test-Path (Join-Path $FrostLocalDir ".git"))) {
    Write-Host "[INFO] rime-frost not found locally. Cloning repository..." -ForegroundColor Yellow
    git clone --depth 1 --branch "$FrostVersion" $FrostRepoUrl $FrostLocalDir
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] git clone failed. The rime-frost repository could not be downloaded." -ForegroundColor Red
        Write-Host "        Hint: This is often a network issue. Please check your connection, VPN, or firewall and try again." -ForegroundColor Gray
        exit 1
    }
    Write-Host "[OK] rime-frost cloned successfully." -ForegroundColor Green
} else {
    Write-Host "[INFO] rime-frost found. Fetching updates..."
    Push-Location $FrostLocalDir
    try {
        git fetch --all
        git checkout "$FrostVersion"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] git checkout of version $FrostVersion failed." -ForegroundColor Red
            exit 1
        }
        git pull origin "$FrostVersion"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] git pull failed. Could not update the rime-frost repository." -ForegroundColor Red
            Write-Host "        Hint: This is often a network issue. Please check your connection, VPN, or firewall and try again." -ForegroundColor Gray
            exit 1
        }
    }
    finally {
        Pop-Location
    }
    Write-Host "[OK] rime-frost is up to date." -ForegroundColor Green
}


# ==============================================================================
# 4. Ensure Weasel User Directory Exists
# ==============================================================================

if (-not (Test-Path $WeaselUserDataDir)) {
    Write-Host "[INFO] Weasel user data directory not found. Creating it..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $WeaselUserDataDir -Force | Out-Null
}

# ==============================================================================
# 5. Install Configurations (Layered)
# ==============================================================================

# --- Layer 1: Install rime-frost as base ---
Write-Host "[INFO] Installing rime-frost files..."
Copy-Item -Path "$FrostLocalDir\*" -Destination $WeaselUserDataDir -Recurse -Force
Write-Host "[OK] rime-frost files installed." -ForegroundColor Green

# --- Layer 2: Install user's custom configurations ---
# --- Copy 'custom' directory ---
$SourceCustomDir = Join-Path $RepoRimeDir "custom"
if (Test-Path $SourceCustomDir) {
    Write-Host "[INFO] Copying 'custom' configuration files (override)..."
    Copy-Item -Path "$SourceCustomDir\*" -Destination $WeaselUserDataDir -Recurse -Force
    Write-Host "[OK] 'custom' directory copied." -ForegroundColor Green
}

# --- Copy 'opencc' directory ---
$SourceOpenccDir = Join-Path $RepoRimeDir "opencc"
if (Test-Path $SourceOpenccDir) {
    Write-Host "[INFO] Copying 'opencc' configuration files (override)..."
    Copy-Item -Path "$SourceOpenccDir\*" -Destination $WeaselUserDataDir -Recurse -Force
    Write-Host "[OK] 'opencc' directory copied." -ForegroundColor Green
}


# ==============================================================================
# 6. Link Sync (User Dictionary) Directory
# ==============================================================================

$DestSyncDir = Join-Path $WeaselUserDataDir "sync"

if (-not (Test-Path $OneDriveSyncDir)) {
    Write-Host "[WARNING] OneDrive sync directory not found at $OneDriveSyncDir. Skipping user dictionary sync." -ForegroundColor Yellow
} else {
    Write-Host "[INFO] Setting up user dictionary synchronization..."
    if (Test-Path $DestSyncDir) {
        $item = Get-Item $DestSyncDir
        if ($item.LinkType -ne "SymbolicLink" -or (Resolve-Path $DestSyncDir) -ne (Resolve-Path $OneDriveSyncDir)) {
             Write-Host "[INFO] Removing existing 'sync' directory/link before creating new link."
             Remove-Item $DestSyncDir -Recurse -Force
        }
    }

    if (-not (Test-Path $DestSyncDir)) {
        try {
            New-Item -ItemType SymbolicLink -Path $DestSyncDir -Target $OneDriveSyncDir -Force | Out-Null
            Write-Host "[OK] Successfully linked user dictionary: $DestSyncDir -> $OneDriveSyncDir" -ForegroundColor Green
        }
        catch {
            Write-Host "[ERROR] Failed to create symbolic link for sync directory." -ForegroundColor Red
            Write-Host "        Reason: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "        Hint: Ensure Developer Mode is ON or run this script as Administrator." -ForegroundColor Gray
        }
    } else {
        Write-Host "[OK] User dictionary is already correctly linked." -ForegroundColor Green
    }
}

# ==============================================================================
# 7. Finalizing
# ==============================================================================
# Copy install timestamp file
Copy-Item -Path $UpstreamVersionFile -Destination $WeaselUserDataDir -Force

Write-Host "Rime (Weasel) configuration completed." -ForegroundColor Green
Write-Host "Please redeploy your Rime input method to apply changes."
