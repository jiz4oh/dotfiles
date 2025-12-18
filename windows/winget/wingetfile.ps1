<#
.SYNOPSIS
    Winget Batch Install Script - For system-level software, databases, and services.
    Recommended to run as [Administrator].
#>

# Check for Administrator privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Warning: It is recommended to run this script as Administrator." -ForegroundColor Yellow
    Write-Host "         (Right-click script -> Select 'Run with PowerShell' as Administrator)" -ForegroundColor Gray
    Start-Sleep -Seconds 3
}

Write-Host "Starting Winget batch installation..." -ForegroundColor Cyan

# -------------------------------------------------------------------------
# Software List
# -------------------------------------------------------------------------
$apps = @(
    # --- 1. Input Methods ---
    "Rime.Weasel",            # Rime (Weasel) Input Method
    
    # --- 2. Databases ---
    # "PostgreSQL.PostgreSQL",
    
    # --- 3. System Integration & Tools ---
    "Bitwarden.Bitwarden",
    "Microsoft.OneDrive",     
    "Padagon.QuickLook",
    "Microsoft.PowerToys",
    "Microsoft.PowerShell"
)

# -------------------------------------------------------------------------
# Installation Loop
# -------------------------------------------------------------------------
foreach ($app in $apps) {
    Write-Host "`nProcessing: $app" -ForegroundColor Cyan
    
    winget install --id $app -e --accept-package-agreements --accept-source-agreements
    
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
        Write-Host "Success: $app processing complete" -ForegroundColor Green
    } else {
        Write-Host "Notice: $app return code: $LASTEXITCODE (Ignore if already installed)" -ForegroundColor Yellow
    }
}

Write-Host "`n-------------------------------------------------------"
Write-Host "All tasks completed!" -ForegroundColor Green
Write-Host "Tips:" -ForegroundColor Yellow
Write-Host "   1. Rime may require a reboot."
Write-Host "   2. PowerShell 7 (if installed) requires a restart of the terminal."
Write-Host "-------------------------------------------------------"
Pause
