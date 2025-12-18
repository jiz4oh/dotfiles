<#
.SYNOPSIS
    Windows Environment Initialization Master Script
    Execution Order: Registry Tweaks -> Winget Install -> Scoop Install
#>
Write-Host "Configuring PowerShell Profile for UTF-8..." -ForegroundColor Cyan

$utf8Settings = @"

# --- Auto-configured by Dotfiles ---
`$OutputEncoding = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::InputEncoding = [System.Text.Encoding]::UTF8
"@

# 检查 Profile 文件是否存在，不存在则创建
if (!(Test-Path $PROFILE)) {
    New-Item -Type File -Path $PROFILE -Force | Out-Null
}

# 将配置追加到 Profile 文件末尾
Add-Content -Path $PROFILE -Value $utf8Settings

Write-Host "PowerShell Profile updated to support UTF-8." -ForegroundColor Green
# Get current script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "Starting Windows environment initialization..." -ForegroundColor Cyan

# 1. Apply Registry Tweaks (Caps -> Ctrl)
Write-Host "`n[1/3] Modifying key mapping (Caps -> Ctrl)..." -ForegroundColor Yellow
$regPath = Join-Path $scriptPath "registry\CapsToCtrl.reg"
if (Test-Path $regPath) {
    # Silently import registry file
    Start-Process reg -ArgumentList "import `"$regPath`"" -Wait -NoNewWindow
    Write-Host "Registry tweaks imported (Requires reboot to take effect)" -ForegroundColor Green
} else {
    Write-Host "Registry file not found" -ForegroundColor Red
}

# 2. Execute Winget Installation (Requires Admin Privileges)
Write-Host "`n[2/3] Installing Winget system-level software..." -ForegroundColor Yellow
$wingetScript = Join-Path $scriptPath "winget\wingetfile.ps1"
if (Test-Path $wingetScript) {
    # Check if running as Admin
    $isUserAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if ($isUserAdmin) {
        & $wingetScript
    } else {
        Write-Host "Non-Admin detected. Requesting elevation to run Winget script..." -ForegroundColor Magenta
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$wingetScript`"" -Verb RunAs -Wait
    }
}

# 3. Execute Scoop Installation (User Level)
Write-Host "`n[3/3] Installing Scoop and development tools..." -ForegroundColor Yellow
$scoopInstaller = Join-Path $scriptPath "scoop\install_scoop.ps1"
# install_scoop.ps1 should contain logic to call scoopfile.ps1
if (Test-Path $scoopInstaller) {
    & $scoopInstaller
}

Write-Host "`nAll steps completed! Please reboot to apply registry changes." -ForegroundColor Green
Pause
