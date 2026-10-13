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

## 按机器用途配置

`chezmoi/.chezmoi.toml.tmpl` 在初始化时生成带中文注释的 `[data]` 开关：

| 开关 | 管理范围 | 默认值 |
| --- | --- | --- |
| `agentTools` | AI 工具清单、skills、原生 plugins、memory hooks、RTK 集成及 agent 配置 | macOS / Omarchy 开启，其他系统关闭 |
| `devTools` | 开发依赖、mise 语言环境与格式化工具、asdf/rbenv 扩展及开发配置 | macOS / Omarchy 开启，其他系统关闭 |
| `desktopApps` | GUI 应用、桌面配置、macOS Rime 词库、终端扩展 | macOS / Omarchy 开启，其他系统关闭 |
| `localServices` | macOS MySQL、PostgreSQL、Redis 安装，以及登记服务的启动 | 关闭 |
| `tailscaleLanBypass` | Linux Tailscale LAN bypass 策略的安装与执行 | 关闭 |

编辑 `chezmoi edit-config` 打开的配置，在 `[data]` 下设置对应布尔值。
旧配置缺少开关时，`.chezmoitemplates/features` 使用同样的系统默认值；显式
`false` 会覆盖默认值。运行 `chezmoi init --source "$PWD"` 可生成带注释的配置，
已有开关值会保留。

开关决定是否管理资源，系统条件仍决定具体实现；开启 `desktopApps` 不会在
Linux 安装 macOS 应用，也没有新增 Linux Rime 安装流程。基础 shell、Git、
编辑器、zsh/tmux 扩展和显式 VPS bootstrap 保留现有管理方式。
关闭开关不会删除已安装的软件、文件、hooks 或 plugins，也不会停止已有服务；
这些已有资源可能继续生效。需要清理时应单独迁移。

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
- `run_after_42_apply_tailscale_lan_bypass.sh.tmpl`：开启 `tailscaleLanBypass` 后，Linux 上每次 apply 都安装并
  运行 `tailscale-lan-bypass`。仅当本机开启 Accept Routes，且物理直连网段与
  Tailscale 接收路由重叠时，添加 `priority 2500 lookup main` 规则。
  检测兼容不支持 `ip -j` 的旧环境，会回退到 `ifconfig`；写入 Linux 策略路由
  仍需要提供 RPDB 接口的 `ip rule`。规则在本次开机期间有效，不配置开机恢复。
  这个绕过只用于网络配置明确且固定的设备。

## Agent skills 与 hooks

- 第一方 skill 统一放在 `chezmoi/dot_agents/skills/`，安装到
  `~/.agents/skills/`；Claude Code 继续通过 `~/.claude/skills` 软链接复用，
  Codex、Gemini CLI 和 OpenCode 直接识别共享目录。
- `agents-memory` 的跨客户端命令 hook 安装到
  `~/.agents/hooks/agents-memory`。`scripts/install_agent_memory_hooks.py` 只合并
  自己标记的 Codex、Claude Code、Gemini CLI hook，保留已有配置；
  `run_after_32_install_agent_memory_hooks.sh.tmpl` 在每次 apply 后幂等执行。
- Codex 会要求审查新增或变化后的个人 hook 定义；这是它的信任机制，chezmoi
  只负责安装和更新文件。

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
