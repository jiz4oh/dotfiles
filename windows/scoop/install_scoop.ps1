<#
.SYNOPSIS
    Scoop Installer with Smart Privilege Detection
    
    Logic:
    1. Built-in Admin (SID -500) -> Installs with -RunAsAdmin
    2. Standard User (Non-Elevated) -> Installs normally
    3. Standard User (Elevated) -> ABORTS (Prevents profile mixing)
#>

$ErrorActionPreference = "Stop"

Write-Host "Starting Scoop Installation..." -ForegroundColor Cyan

# ==============================================================================
# 1. User Identity & Privilege Check
# ==============================================================================
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isBuiltInAdmin = $identity.User.Value.EndsWith("-500")

if ($isAdmin -and -not $isBuiltInAdmin) {
    Write-Host "----------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "SKIPPED: You are running as a Standard User with Elevated Privileges." -ForegroundColor Yellow
    Write-Host "Reason: Installing Scoop in this mode will install it to the Administrator's" -ForegroundColor Gray
    Write-Host "        profile instead of yours. This causes path and permission errors." -ForegroundColor Gray
    Write-Host "Action: Please run this script in a NON-ADMIN terminal." -ForegroundColor White
    Write-Host "----------------------------------------------------------------" -ForegroundColor Yellow
    exit 0
}

# ==============================================================================
# 2. Download Official Installer
# ==============================================================================
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

if ($isBuiltInAdmin) {
    Write-Host "NOTICE: Running as Built-in Administrator. Installing with global privileges." -ForegroundColor Yellow
    & $installerPath -RunAsAdmin
} else {
    Write-Host "Running as Standard User." -ForegroundColor Gray
    & $installerPath
}

if (Test-Path $installerPath) { Remove-Item $installerPath -Force }

# ==============================================================================
# 4. Refresh Environment Variables
# ==============================================================================
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Scoop installed successfully." -ForegroundColor Green
} else {
    Write-Host "Error: Scoop command not found after installation." -ForegroundColor Red
    exit 1
}

# ==============================================================================
# 5. Install Essentials
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

Write-Host "`nScoop setup completed!" -ForegroundColor Green
