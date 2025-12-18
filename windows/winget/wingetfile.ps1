<#
.SYNOPSIS
    Winget Batch Install Script - For system-level software, databases, and services.
    Recommended to run as [Administrator].
#>

# Check for Administrator privileges (Required for databases and input methods)
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Warning: It is recommended to run this script as Administrator to ensure successful installation." -ForegroundColor Yellow
    Write-Host "         (Right-click script -> Select 'Run with PowerShell' as Administrator)" -ForegroundColor Gray
    Start-Sleep -Seconds 3
}

Write-Host "Starting Winget batch installation..." -ForegroundColor Cyan

# -------------------------------------------------------------------------
# Software List (ID List)
# -------------------------------------------------------------------------
$apps = @(
    # --- 1. Input Methods ---
    "Rime.Weasel",            # Rime (Weasel) Input Method
    
    # --- 2. Databases (with Services) ---
    # "PostgreSQL.PostgreSQL",  # PostgreSQL
    
    # --- 3. System Integration & Common Tools ---
    "Bitwarden.Bitwarden",
    "Microsoft.OneDrive",     # Usually pre-installed; installs if missing
    "Padagon.QuickLook",
    "Microsoft.PowerToys"
)

# -------------------------------------------------------------------------
# Installation Loop
# -------------------------------------------------------------------------
foreach ($app in $apps) {
    Write-Host "`nProcessing: $app" -ForegroundColor Cyan
    
    # Check if installed (Winget list is slow, so we attempt install directly using native checks)
    # Parameters:
    # -e / --exact : Exact ID match to avoid installing the wrong package
    # --accept-package-agreements : Automatically accept license agreements
    # --accept-source-agreements : Automatically accept source agreements
    
    winget install --id $app -e --accept-package-agreements --accept-source-agreements
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Success: $app processing complete" -ForegroundColor Green
    } else {
        Write-Host "Notice: $app return code: $LASTEXITCODE (Ignore if already installed)" -ForegroundColor Yellow
    }
}

Write-Host "`n-------------------------------------------------------"
Write-Host "All tasks completed!" -ForegroundColor Green
Write-Host "Tips:" -ForegroundColor Yellow
Write-Host "   1. Rime (Weasel) may require a logout or reboot to take effect."
Write-Host "   2. For MySQL/PGSQL, please check service status manually (Win+R -> services.msc)."
Write-Host "-------------------------------------------------------"
Pause
