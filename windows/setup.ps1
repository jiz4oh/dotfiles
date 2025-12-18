<#
.SYNOPSIS
    Windows 环境一键初始化脚本 (Master Script)
    按顺序执行：注册表修改 -> Winget 安装 -> Scoop 安装
#>

# 获取当前脚本所在目录
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "🚀 开始 Windows 环境初始化..." -ForegroundColor Cyan

# 1. 应用注册表 (Caps -> Ctrl)
Write-Host "`n⌨️ [1/3] 修改键位映射 (Caps -> Ctrl)..." -ForegroundColor Yellow
$regPath = Join-Path $scriptPath "registry\CapsToCtrl.reg"
if (Test-Path $regPath) {
    # 静默导入注册表
    Start-Process reg -ArgumentList "import `"$regPath`"" -Wait -NoNewWindow
    Write-Host "✅ 键位修改已导入 (重启后生效)" -ForegroundColor Green
} else {
    Write-Host "⚠️ 未找到注册表文件" -ForegroundColor Red
}

# 2. 执行 Winget 安装 (需要管理员权限)
Write-Host "`n📦 [2/3] 安装 Winget 系统级软件..." -ForegroundColor Yellow
$wingetScript = Join-Path $scriptPath "winget\wingetfile.ps1"
if (Test-Path $wingetScript) {
    # 检查当前是否为管理员，如果不是则提示
    $isUserAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if ($isUserAdmin) {
        & $wingetScript
    } else {
        Write-Host "⚠️ 检测到非管理员权限，正在请求提权运行 Winget 脚本..." -ForegroundColor Magenta
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$wingetScript`"" -Verb RunAs -Wait
    }
}

# 3. 执行 Scoop 安装 (用户级权限)
Write-Host "`n🍦 [3/3] 安装 Scoop 及开发工具..." -ForegroundColor Yellow
$scoopInstaller = Join-Path $scriptPath "scoop\install_scoop.ps1"
# 这里的 install_scoop.ps1 应该包含调用 scoopfile.ps1 的逻辑
if (Test-Path $scoopInstaller) {
    & $scoopInstaller
}

Write-Host "`n🎉 所有步骤执行完毕！请重启电脑以应用注册表更改。" -ForegroundColor Green
Pause
