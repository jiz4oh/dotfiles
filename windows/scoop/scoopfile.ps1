<#
.SYNOPSIS
    Scoopfile - Your Windows Software List
    Right-click this file -> Select "Run with PowerShell" to install/restore software.
#>

Write-Host "Reading Scoopfile manifest..." -ForegroundColor Cyan

# -------------------------------------------------------------------------
# 1. Configure Buckets (Software Sources)
# -------------------------------------------------------------------------
$buckets = @(
    "extras",      # GUI Software (Firefox, Telegram, Obsidian, etc.)
    "versions",    # Multi-version support (PostgreSQL 14)
    "nerd-fonts"   # Fonts (Hack Nerd Font)
)

foreach ($bucket in $buckets) {
    scoop bucket add $bucket
}

# -------------------------------------------------------------------------
# 2. Software List
# -------------------------------------------------------------------------
$apps = @(
  # --- Core Dev Tools ---
  "git",
  "mise",            # Version management
  "yarn",
  "python",          # Recommended, many tools depend on it
  "gsudo",
  
  # --- CLI Power Tools ---
  "bat",
  "curl",
  "wget",
  "httpie",
  "jq",              # Recommended: JSON processor
  "ripgrep",         # Recommended: Faster grep
  "fzf",             # Recommended: Fuzzy finder
  "tree",
  "universal-ctags",
  "gnupg",
  "translate-shell",
  
  # --- Mobile Dev ---
  "adb",             # (scoop install android-platform-tools)
  "scrcpy",
  
  # --- Portable GUI Tools (Best managed by Scoop) ---
  "pixpin",          # Screenshot tool
  "telegram",        # Portable version, easy updates
  "obsidian",        # Notes
  "localsend",       # LAN transfer
  "screentogif",
  "carnac",
  "autohotkey",
  
  # --- Fonts ---
  "hack-nf"
)

# -------------------------------------------------------------------------
# 3. Batch Install/Update Logic
# -------------------------------------------------------------------------
Write-Host "`nStarting software synchronization..." -ForegroundColor Cyan

foreach ($app in $apps) {
    if (!(scoop list $app)) {
        Write-Host "Installing: $app ..." -ForegroundColor Yellow
        scoop install $app
    } else {
        Write-Host "Checking for updates: $app ..." -ForegroundColor Cyan
        scoop update $app
    }
}

Write-Host "`nScoopfile execution completed!" -ForegroundColor Green
Pause
