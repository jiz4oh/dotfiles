<#
.SYNOPSIS
    Winget 批量安装脚本 - 针对系统级软件、数据库和服务
    建议以【管理员身份】运行此脚本
#>

# 检查是否为管理员权限 (数据库和输入法通常需要)
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "⚠️  建议以管理员身份运行此脚本，以确保数据库和输入法安装成功。" -ForegroundColor Yellow
    Write-Host "    (右键点击脚本 -> 选择 '以管理员身份运行')" -ForegroundColor Gray
    Start-Sleep -Seconds 3
}

Write-Host "🚀 开始执行 Winget 批量安装..." -ForegroundColor Cyan

# -------------------------------------------------------------------------
# 软件清单 (ID 列表)
# -------------------------------------------------------------------------
$apps = @(
    # --- 1. 输入法 ---
    "Rime.Weasel",            # 小狼毫输入法
    
    # --- 2. 数据库 (带服务) ---
    # "PostgreSQL.PostgreSQL",  # PostgreSQL
    
    # --- 3. 系统集成与常用 ---
    "Bitwarden.Bitwarden",
    "Microsoft.OneDrive"      # 系统通常自带，若未安装会自动安装
)

# -------------------------------------------------------------------------
# 安装循环
# -------------------------------------------------------------------------
foreach ($app in $apps) {
    Write-Host "`n⬇️  正在处理: $app" -ForegroundColor Cyan
    
    # 检查是否已安装 (Winget list 比较慢，这里直接尝试 install，依靠 winget 自身的检测机制)
    # 参数解释：
    # -e / --exact : 精确匹配 ID，防止装错软件
    # --accept-package-agreements : 自动同意软件协议
    # --accept-source-agreements : 自动同意源协议
    # --silent : 静默安装 (部分软件可能不支持，仍会弹窗，但大部分有效)
    
    winget install --id $app -e --accept-package-agreements --accept-source-agreements
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ $app 处理完成" -ForegroundColor Green
    } else {
        Write-Host "⚠️ $app 安装返回代码: $LASTEXITCODE (如果显示已安装可忽略)" -ForegroundColor Yellow
    }
}

Write-Host "`n-------------------------------------------------------"
Write-Host "🎉 所有任务执行完毕！" -ForegroundColor Green
Write-Host "💡 提示：" -ForegroundColor Yellow
Write-Host "   1. Rime (小狼毫) 安装后可能需要【注销或重启】电脑才能生效。"
Write-Host "   2. MySQL/PGSQL 安装后，请手动检查服务状态 (Win+R -> services.msc)。"
Write-Host "-------------------------------------------------------"
Pause
