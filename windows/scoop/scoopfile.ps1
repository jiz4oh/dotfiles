<#
.SYNOPSIS
    Scoopfile - 你的 Windows 软件清单
    右键点击此文件 -> 选择 "使用 PowerShell 运行" 即可安装/恢复所有软件。
#>

Write-Host "📜 读取 Scoopfile 清单..." -ForegroundColor Cyan

# -------------------------------------------------------------------------
# 1. 配置 Bucket (软件源)
# -------------------------------------------------------------------------
$buckets = @(
    "extras",      # GUI 软件 (Firefox, Telegram, Obsidian 等)
    "versions",    # 多版本支持 (PostgreSQL 14)
    "nerd-fonts"   # 字体 (Hack Nerd Font)
)

foreach ($bucket in $buckets) {
    scoop bucket add $bucket
}

# -------------------------------------------------------------------------
# 2. 软件列表
# -------------------------------------------------------------------------
$apps = @(
    # --- 核心开发工具 ---
    "git",
    "mise",            # 版本管理
    "yarn",
    "python",          # 建议加上 python，很多工具依赖它
    
    # --- 命令行神器 ---
    "bat",
    "curl",
    "wget",
    "httpie",
    "jq",              # 推荐补充：处理 JSON 的神器
    "ripgrep",         # 推荐补充：比 grep 快得多的搜索工具
    "fzf",             # 推荐补充：模糊搜索
    "tree",
    "universal-ctags",
    "gnupg",
    "translate-shell",
    
    # --- 移动开发 ---
    "adb",             # (scoop install android-platform-tools)
    "scrcpy",
    
    # --- 绿色版 GUI 工具 (Scoop 管理非常完美) ---
    "pixpin",          # 截图
    "telegram",        # 电报便携版，升级很方便
    "obsidian",        # 笔记
    "localsend",       # 局域网传输
    
    # --- 字体 ---
    "hack-nf"
)

# -------------------------------------------------------------------------
# 3. 批量安装/更新逻辑
# -------------------------------------------------------------------------
Write-Host "`n🚀 开始同步软件..." -ForegroundColor Cyan

foreach ($app in $apps) {
    if (!(scoop list $app)) {
        Write-Host "➕ 正在安装: $app ..." -ForegroundColor Yellow
        scoop install $app
    } else {
        Write-Host "🔄 正在检查更新: $app ..." -ForegroundColor Cyan
        scoop update $app
    }
}

Write-Host "`n✨ Scoopfile 执行完毕！" -ForegroundColor Green
Pause
