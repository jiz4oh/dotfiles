# Chezmoi 结构说明

这个仓库根目录就是 `chezmoi` 的 source dir。简单文件优先使用原生
`dot_*` 命名，大型或可变目录使用显式 `symlink_*` 或 external 管理。

## 日常命令

```sh
chezmoi --source "$PWD" managed
chezmoi --source "$PWD" apply --dry-run --force --no-tty
chezmoi --source "$PWD" apply --force --no-tty
```

查看差异：

```sh
chezmoi --source "$PWD" diff
```

## 当前覆盖范围

这次迁移已经把旧 `install` 脚本里的主要内容收进 `chezmoi`：

- shell、git、tmux、编辑器、格式化工具等简单 dotfiles，使用原生
  `dot_*` 形式管理
- `~/.config/direnv/direnv.toml`、`~/.config/lemonade.toml`、
  `~/.codex/AGENTS.md`、`~/.rbenv/default-gems`、
  `~/.snipaste/config.ini`、`~/.hammerspoon/init.lua` 这类单文件或浅层目录
- `~/.agents`、`~/.vim`、`~/.raycast`、`~/.terminfo`、
  `~/.config/{kitty,rubocop,solargraph,wezterm}`、
  `~/.hammerspoon/{Spoons,modules}` 这类大目录，使用 symlink 管理
- `~/.config/mise` 由仓库内 `chezmoi/dot_config/mise/` 直接管理（不再走 symlink）
- 原先的 git submodule 现在统一放进 `chezmoi/.chezmoiexternals/`：
  `~/.config/kitty/kitty_search` 以及
  `~/.agents/skill-sources/{git-commit-helper,notebooklm-skill,ordinary-claude-skills,superpowers}`
- Rime 上游仓库通过 external 落到 `~/.local/share/rime-frost`，本地覆盖层继续放在
  `rime/custom` 和 `rime/opencc`

## 脚本约定

会修改机器状态的步骤统一放在 `chezmoi/.chezmoiscripts/`：

- `run_once_*`：只执行一次的初始化步骤
- `run_onchange_*`：脚本内容变化时重新执行
- `run_after_*`：每次 `chezmoi apply` 完成后执行
- `run_before_20_refresh_cached_env.sh.tmpl`：每次 apply 前按 `.chezmoidata/cached-env.yaml` 刷新本机 `~/.local/state/chezmoi/cached-env.env`；单项刷新失败时 warning、保留该项上一版缓存并继续其他项
- `run_onchange_after_29_install_tmux_tpm.sh.tmpl`：目录准备完成后幂等安装或刷新 TPM，避免 external 刷新早于父目录创建
- `run_after_42_apply_tailscale_lan_bypass.sh.tmpl`：Linux 上每次 apply 都安装并
  运行 `tailscale-lan-bypass`。仅当本机开启 Accept Routes，且物理直连网段与
  Tailscale 接收路由重叠时，添加 `priority 2500 lookup main` 规则。
  检测兼容不支持 `ip -j` 的旧环境，会回退到 `ifconfig`；写入 Linux 策略路由
  仍需要提供 RPDB 接口的 `ip rule`。规则在本次开机期间有效，不配置开机恢复。
  这个绕过只用于网络配置明确且固定的设备。

## Shell 与 PATH 策略

macOS 和 Linux 都保留 Bash 作为账户、自动化和 SSH 命令 Shell，交互式
Bash 再通过受保护的 `exec zsh` 进入 zsh。这样依赖 `$SHELL -lc` 的 Neovim
插件和任务运行器统一使用 Bash，日常终端继续使用 Oh My Zsh 和
Powerlevel10k。

macOS 的 `/etc/profile` 和 `/etc/zprofile` 会运行 `path_helper`，将系统目录
重新排到继承 PATH 的前面。过去 `.zpath` 导出的 `_ZPATH_LOADED=1` 会被子
login shell 继承，导致 `.bash_profile` 或 `.zprofile` 无法在 `path_helper`
之后恢复个人目录顺序，mise 安装的工具可能因此被系统或 Homebrew 同名程序
覆盖。

当前约定是：

- `.zpath` 是 Bash 和 zsh 共享、可重复加载的 PATH 真源；每次加载后按首次
  出现位置去重
- `.shenv` 只保存非交互 shell 也需要的环境变量；依赖 TTY、可能启动
  `ssh-agent` 的操作放在仅由交互 shell 加载的 `.shellrc`
- 启动文件先加载 `.shenv` 解析 `_DOTFILES_PATH`，再加载 `.zpath`，确保
  全新环境也能加入仓库自己的 `bin`
- `.bash_profile` 和 `.zprofile` 必须在系统 login profile 之后加载
  `.zpath`
- `.zshenv` 只为非 login、非交互 zsh 加载 `.zpath`；login zsh 等待
  `.zprofile`，交互 zsh 由 `.zshrc` 处理
- mise 采用 shims-only 模式，`~/.local/share/mise/shims` 保持在 Homebrew
  和系统目录之前；项目需要严格版本边界时使用 `mise exec -- <command>`
- 不全局设置 `BASH_ENV`，避免普通 Bash 脚本隐式加载用户配置
- Omarchy 继续拥有 `/usr/share/omarchy`；交互启动文件只读取它的
  `env-bootstrap`，不安装或覆盖使用者的 zsh 框架

chezmoi 不自动修改账户 Shell。新机器应用配置并确认 Bash、zsh 都可用后，
手动执行 `chsh -s /bin/bash`；重新登录后 `$SHELL` 应为 `/bin/bash`，交互
进程应为 zsh。

## 包管理

声明式包清单放在 `chezmoi/.chezmoidata/`。当前唯一真源是：

```text
chezmoi/.chezmoidata/packages.yaml
```

对应安装脚本：

- macOS：`run_onchange_before_06_install_packages_macos.sh.tmpl`
- Linux：`run_onchange_before_41_install_packages_linux.sh.tmpl`

## 手动脚本

不应该在 `chezmoi apply` 期间自动执行的 helper，继续放在
`.chezmoiscripts/` 之外。

Rime 这块的约定是：

- 用户手动入口保留在 `rime/`
- 自动同步入口在 `chezmoi/.chezmoiscripts/run_after_41_sync_rime.sh.tmpl`
- macOS 专属落盘与 `sync` 处理收敛到 `rime/install_osx`

## 备注

- `.chezmoiignore` 会忽略原始仓库文件，只让原生 `dot_*`、显式 `symlink_*`
  和脚本映射参与 apply（当前文件为 `.chezmoiignore.tmpl`）
- 可执行文件统一使用 `executable_*` 前缀（如 `bin/`、`dot_git_template/hooks/`）
- 还在使用的 symlink 目标统一引用 `{{ .chezmoi.sourceDir }}`，这样 source dir
  挪位置后不用改路径
- 旧 `install` 脚本现在只适合做遗留的软件安装、插件安装或系统初始化补充，不再作为
  dotfiles 落盘主入口
- `oh-my-zsh/custom` 目前没有整体切成 symlink，因为很多机器已经有现成的
  Oh My Zsh 目录；后续要不要整体接管，先看目标机器的实际安装状态
