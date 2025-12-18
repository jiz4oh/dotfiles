# ==========================================
# Scoop 安装器 (支持自动调用 Scoopfile)
# ==========================================

Write-Host "⏳ [1/4] 设置执行策略..." -ForegroundColor Cyan
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Write-Host "⬇️ [2/4] 安装 Scoop..." -ForegroundColor Cyan
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# 检查 Scoop 是否安装成功
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Scoop 安装似乎遇到了问题，尝试刷新环境变量..." -ForegroundColor Yellow
    # 尝试在当前会话中刷新 Path，以便后续命令能找到 scoop
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
}

Write-Host "🚀 [3/4] 安装必备加速组件 (Git & Aria2)..." -ForegroundColor Cyan
scoop install git
scoop install aria2
scoop config aria2-warning-enabled false
scoop config aria2-max-connection-per-server 16
scoop config aria2-split 16
scoop config aria2-min-split-size 1M

# ==========================================
# 自动调用 Scoopfile
# ==========================================
Write-Host "📜 [4/4] 检查 Scoopfile..." -ForegroundColor Cyan

# 获取当前脚本所在的目录
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scoopfilePath = Join-Path $scriptPath "Scoopfile.ps1"

if (Test-Path $scoopfilePath) {
    Write-Host "✅ 发现 Scoopfile，正在导入你的软件清单..." -ForegroundColor Green
    # 调用 Scoopfile
    & $scoopfilePath
} else {
    Write-Host "⚠️ 未找到 Scoopfile.ps1，仅完成了基础安装。" -ForegroundColor Yellow
    Write-Host "你可以创建一个 Scoopfile.ps1 来批量管理软件。" -ForegroundColor Gray
}

Write-Host "`n🎉 全部完成！" -ForegroundColor Green
