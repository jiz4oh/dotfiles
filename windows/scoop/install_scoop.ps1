<#
.SYNOPSIS
    Scoop Installer (Compatible with both User and Admin modes)
    Supports auto-invoking Scoopfile.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host "Starting Scoop Installation..." -ForegroundColor Cyan

# ==============================================================================
# 1. Check Permissions
# ==============================================================================
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# ==============================================================================
# 2. Download Official Installer
# ==============================================================================
# We download to a file instead of using IEX so we can pass arguments (like -RunAsAdmin)
$installerUrl = "https://get.scoop.sh"
$installerPath = "$env:TEMP\scoop_installer.ps1"

Write-Host "[1/5] Downloading Scoop installer..." -ForegroundColor Gray
try {
    Invoke-RestMethod -Uri $installerUrl -OutFile $installerPath
} catch {
    Write-Host "Error downloading Scoop installer. Check internet connection." -ForegroundColor Red
    exit 1
}

# ==============================================================================
# 3. Install Scoop
# ==============================================================================
Write-Host "[2/5] Executing installer..." -ForegroundColor Cyan

if ($isAdmin) {
    Write-Host "NOTICE: Running as Administrator. Installing with global privileges." -ForegroundColor Yellow
    # Execute with -RunAsAdmin flag
    & $installerPath -RunAsAdmin
} else {
    Write-Host "Running as Standard User." -ForegroundColor Gray
    # Execute normally
    & $installerPath
}

# Cleanup temp file
if (Test-Path $installerPath) { Remove-Item $installerPath -Force }

# ==============================================================================
# 4. Refresh Environment Variables
# ==============================================================================
# Critical: Refresh Path so 'scoop' command works immediately in this session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Scoop installed successfully." -ForegroundColor Green
} else {
    Write-Host "Error: Scoop command not found after installation." -ForegroundColor Red
    Write-Host "You may need to restart your terminal." -ForegroundColor Yellow
    exit 1
}

# ==============================================================================
# 5. Install Essentials (Git & Aria2)
# ==============================================================================
Write-Host "[3/5] Installing essential components..." -ForegroundColor Cyan

# Install Aria2 (Download accelerator)
if (!(scoop list aria2)) { 
    Write-Host "Installing Aria2..." -ForegroundColor Gray
    scoop install aria2 
    scoop config aria2-warning-enabled false
    scoop config aria2-max-connection-per-server 16
    scoop config aria2-split 16
    scoop config aria2-min-split-size 1M
}

# ==============================================================================
# 6. Auto-invoke Scoopfile
# ==============================================================================
Write-Host "[4/5] Checking for Scoopfile.ps1..." -ForegroundColor Cyan

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scoopfilePath = Join-Path $scriptPath "Scoopfile.ps1"

if (Test-Path $scoopfilePath) {
    Write-Host "Scoopfile found. Invoking software list..." -ForegroundColor Green
    & $scoopfilePath
} else {
    Write-Host "Scoopfile.ps1 not found. Skipping batch installation." -ForegroundColor Yellow
}

Write-Host "`nAll completed!" -ForegroundColor Green
