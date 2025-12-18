<#
.SYNOPSIS
    Windows Environment Initialization Master Script
    Execution Order: 
    1. Registry Tweaks (Elevated)
    2. Winget Install (Elevated)
    3. Scoop Install (User)
    4. Link Dotfiles (User)
    
    NOTE: Please run this script as a STANDARD USER (Not Administrator).
    It will automatically ask for Admin permissions for the steps that need it.
#>

# Get current script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "Starting Windows environment initialization..." -ForegroundColor Cyan

# ==============================================================================
# 0. Configure PowerShell Profile for UTF-8 (Optional)
# ==============================================================================
Write-Host "`n[0/4] Checking PowerShell Profile encoding settings..." -ForegroundColor Cyan

# Check if Profile exists, create if not
if (!(Test-Path $PROFILE)) {
    New-Item -Type File -Path $PROFILE -Force | Out-Null
    Write-Host "Created new PowerShell profile." -ForegroundColor Gray
}

# The settings to add
$utf8Settings = @"

# --- Auto-configured by Dotfiles ---
`$OutputEncoding = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::InputEncoding = [System.Text.Encoding]::UTF8
"@

# Check if settings already exist to avoid duplicate entries
$profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -notmatch "Auto-configured by Dotfiles") {
    Add-Content -Path $PROFILE -Value $utf8Settings
    Write-Host "UTF-8 settings appended to Profile." -ForegroundColor Green
} else {
    Write-Host "UTF-8 settings already exist in Profile. Skipping." -ForegroundColor Gray
}

# ==============================================================================
# 1. Check Current Permissions
# ==============================================================================
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "WARNING: You are running this script as Administrator." -ForegroundColor Yellow
    Write-Host "Scoop installation will be SKIPPED because it does not support Admin privileges." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}

# ==============================================================================
# 2. Apply Registry Tweaks (Caps -> Ctrl) - Requires Admin
# ==============================================================================
Write-Host "`n[1/4] Modifying key mapping (Caps -> Ctrl)..." -ForegroundColor Cyan
$regPath = Join-Path $scriptPath "registry\CapsToCtrl.reg"

if (Test-Path $regPath) {
    if ($isAdmin) {
        # Already Admin, run directly
        Start-Process reg -ArgumentList "import `"$regPath`"" -Wait -NoNewWindow
        Write-Host "Registry tweaks imported." -ForegroundColor Green
    } else {
        # Not Admin, request elevation
        Write-Host "Requesting Admin permission for Registry import..." -ForegroundColor Magenta
        Start-Process reg -ArgumentList "import `"$regPath`"" -Verb RunAs -Wait
        Write-Host "Elevation command sent." -ForegroundColor Green
    }
} else {
    Write-Host "Error: Registry file not found at $regPath" -ForegroundColor Red
}

# ==============================================================================
# 3. Execute Winget Installation - Requires Admin
# ==============================================================================
Write-Host "`n[2/4] Installing Winget system-level software..." -ForegroundColor Cyan
$wingetScript = Join-Path $scriptPath "winget\wingetfile.ps1"

if (Test-Path $wingetScript) {
    if ($isAdmin) {
        # Already Admin, run directly
        & $wingetScript
    } else {
        # Not Admin, request elevation to run the winget script in a new window
        Write-Host "Requesting Admin permission for Winget..." -ForegroundColor Magenta
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$wingetScript`"" -Verb RunAs -Wait
        Write-Host "Winget step completed." -ForegroundColor Green
    }
} else {
    Write-Host "Error: Winget script not found at $wingetScript" -ForegroundColor Red
}

# ==============================================================================
# 4. Execute Scoop Installation - REQUIRES NON-ADMIN
# ==============================================================================
Write-Host "`n[3/4] Installing Scoop and development tools..." -ForegroundColor Cyan

# We no longer skip if Admin. The install_scoop.ps1 now handles Admin logic.
if ($isAdmin) {
    Write-Host "Notice: Installing Scoop in Administrator mode." -ForegroundColor Yellow
}

$scoopInstaller = Join-Path $scriptPath "scoop\install_scoop.ps1"
if (Test-Path $scoopInstaller) {
    & $scoopInstaller
} else {
    Write-Host "Error: Scoop installer not found at $scoopInstaller" -ForegroundColor Red
}

# ==============================================================================
# 5. Link Configuration Files - User Mode
# ==============================================================================
Write-Host "`n[4/4] Linking Configuration Files..." -ForegroundColor Cyan

if ($isAdmin) {
    Write-Host "WARNING: Linking files as Administrator may cause path issues ($HOME)." -ForegroundColor Yellow
}

# Call the standalone linking script
$linkScript = Join-Path $scriptPath "link.ps1"

if (Test-Path $linkScript) {
    & $linkScript
} else {
    Write-Host "Error: Linking script not found at $linkScript" -ForegroundColor Red
}

# ==============================================================================
# End
# ==============================================================================
Write-Host "`nAll steps completed." -ForegroundColor Green
Write-Host "Note: Registry changes require a reboot to take effect." -ForegroundColor Gray
Write-Host "`n----------------------------------------"
Read-Host "Press Enter to exit"
