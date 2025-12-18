<#
.SYNOPSIS
    Configuration Linking Manifest
    This script maps files from the repository to the local system.
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "Starting Configuration Linking..." -ForegroundColor Cyan

# ==============================================================================
# 1. Define Function
# ==============================================================================
function Link-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Source,

        [Parameter(Mandatory=$true)]
        [string]$Dest
    )

    # 1. Check if source exists
    if (-not (Test-Path $Source)) {
        Write-Host "[SKIP] Source file not found: $Source" -ForegroundColor Yellow
        return
    }

    # 2. Check destination
    if (Test-Path $Dest) {
        $item = Get-Item $Dest
        
        # If it is already a symbolic link
        if ($item.LinkType -eq "SymbolicLink") {
            # Ideally we check target, but for simplicity we remove and re-link
            Remove-Item $Dest -Force
        } 
        # If it is a real file/folder, backup it
        else {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
            $backupName = "$($item.Name).$timestamp.bak"
            Write-Host "[INFO] Backing up existing file to $backupName" -ForegroundColor Gray
            Rename-Item $Dest -NewName $backupName -Force
        }
    }

    # 3. Create Parent Directory if missing
    $parentDir = Split-Path $Dest -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    # 4. Create the Symbolic Link
    try {
        New-Item -ItemType SymbolicLink -Path $Dest -Target $Source -Force | Out-Null
        Write-Host "[OK] Linked: $Dest -> $Source" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to create link for $Dest" -ForegroundColor Red
        Write-Host "        Reason: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "        Hint: Ensure Developer Mode is ON or run as Administrator." -ForegroundColor Gray
    }
}

# ==============================================================================
# 2. Define Repository Root
# ==============================================================================
# Assuming structure: dotfiles/windows/link_all.ps1
# We need to go up 2 levels to find 'dotfiles' root (where 'home' folder is)
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..")

Write-Host "Repository Root detected at: $RepoRoot" -ForegroundColor Gray

# ==============================================================================
# 3. Define Links
# ==============================================================================

# --- Git Config ---
Link-File -Source "$RepoRoot\gitconfig" -Dest "$HOME\.gitconfig"
Link-File -Source "$RepoRoot\git_template" -Dest "$HOME\.git_template"
Link-File -Source "$RepoRoot\gitignore" -Dest "$HOME\.gitignore"

# --- PowerShell Profile ---
# Current User, Current Host
Link-File -Source "$RepoRoot\config\powershell\profile.ps1" -Dest "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# --- Windows Terminal ---
$TerminalPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Link-File -Source "$RepoRoot\config\terminal\settings.json" -Dest $TerminalPath

Write-Host "Configuration linking completed." -ForegroundColor Green
