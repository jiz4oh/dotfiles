# ==========================================
# Scoop Installer (Supports auto-invoking Scoopfile)
# ==========================================

Write-Host "[1/4] Setting execution policy..." -ForegroundColor Cyan
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Write-Host "[2/4] Installing Scoop..." -ForegroundColor Cyan
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Check if Scoop installed successfully
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop installation might have issues, attempting to refresh environment variables..." -ForegroundColor Yellow
    # Attempt to refresh Path in current session so subsequent commands can find scoop
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
}

Write-Host "[3/4] Installing essential components (Git & Aria2)..." -ForegroundColor Cyan
scoop install git
scoop install aria2
scoop config aria2-warning-enabled false
scoop config aria2-max-connection-per-server 16
scoop config aria2-split 16
scoop config aria2-min-split-size 1M

# ==========================================
# Auto-invoke Scoopfile
# ==========================================
Write-Host "[4/4] Checking for Scoopfile..." -ForegroundColor Cyan

# Get current script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scoopfilePath = Join-Path $scriptPath "Scoopfile.ps1"

if (Test-Path $scoopfilePath) {
    Write-Host "Scoopfile found, importing software list..." -ForegroundColor Green
    # Invoke Scoopfile
    & $scoopfilePath
} else {
    Write-Host "Scoopfile.ps1 not found, only base installation completed." -ForegroundColor Yellow
    Write-Host "You can create a Scoopfile.ps1 to manage software in batches." -ForegroundColor Gray
}

Write-Host "`nAll completed!" -ForegroundColor Green
