# 1. 切换到 Linux 用户习惯的 Emacs 模式 (修复 Ctrl+A, Ctrl+E, Ctrl+K 等)
Set-PSReadLineOption -EditMode Emacs

# 2. 特殊修复 Ctrl+D
# 在 Bash 中，空行按 Ctrl+D 是退出 (EOF)，非空行是删除字符。
# PowerShell 默认即便在 Emacs 模式下，Ctrl+D 也只是删除字符。
# 下面的配置模拟 Bash 的行为：
Set-PSReadLineKeyHandler -Key Ctrl+d -ScriptBlock {
    $cursorColumn = $host.UI.RawUI.CursorPosition.X
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ([string]::IsNullOrEmpty($line)) {
        # 如果当前行是空的，执行退出
        exit
    } else {
        # 如果当前行有字，执行原本的“删除字符”功能
        [Microsoft.PowerShell.PSConsoleReadLine]::DeleteChar()
    }
}

# 解决 pwsh 在 ssh 下不生效的问题
$DockerPath = "C:\Program Files\Docker\Docker\resources\bin"
if ($env:Path -notlike "*$DockerPath*") {
    $env:Path += ";$DockerPath"
}
