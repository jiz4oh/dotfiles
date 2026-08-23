# Omarchy 4 与 chezmoi/mise 集成方案

记录日期：2026-08-23

## 结论

在 Omarchy 上保留 Bash 作为账户 shell；交互式 Bash 再以防递归方式进入
zsh。`~/.config/mise/config.toml` 继续由 chezmoi 管理，但在 Omarchy 上
不声明已经由 pacman 提供的通用 CLI。macOS 和其他 Linux 保持原配置。

这是基于 Omarchy 4 当前手册、Omarchy v4.0.0 源码、omacom-io 的
`omarchy-zsh` 实现以及 mise 官方配置规则得出的集成边界。

## 官方行为

### Dotfiles 与系统文件

Omarchy 手册将 `~/.config` 定义为用户可修改、可备份的配置目录；
`/usr/share/omarchy` 属于 Omarchy 包，不应直接修改，因为更新会覆盖。
手册还明确建议把自定义 export、alias 和 function 放入 `~/.bashrc`。

来源：

- <https://omarchy.org/manual/dotfiles/>

### Bash 与 zsh

Omarchy 4 默认 Bash 启动链在交互 shell 中加载 `default/bash/rc`，其中包含
Omarchy 的环境、alias、function、mise activation 和补全。v4.0.0 的
`env-bootstrap` 也会被登录 shell、交互 Bash 和 UWSM 会话加载，并把
mise shims 与 `~/.local/bin` 追加到 PATH，使系统程序保持优先。

omacom-io 的 `omarchy-zsh` 没有通过 `chsh` 改账户 shell。它保留 Bash，
在交互式 `.bashrc` 中检查父进程、`BASH_EXECUTION_STRING` 和 `SHLVL` 后
`exec zsh`，并让 zsh 从 `/usr/share/omarchy-zsh` 加载共享配置。

来源：

- <https://github.com/basecamp/omarchy/blob/v4.0.0/default/bash/env-bootstrap>
- <https://github.com/basecamp/omarchy/blob/v4.0.0/default/bash/init>
- <https://github.com/omacom-io/omarchy-zsh/blob/master/templates/bashrc>
- <https://github.com/omacom-io/omarchy-zsh/blob/master/templates/zshrc>

### mise 全局配置

Omarchy 手册要求使用 `mise use -g ruby` 之类的命令安装并设置全局运行时。
安装流程也执行 `mise use -g node@latest`。AI CLI 则由
`omarchy-mise-install` 创建 `~/.local/bin` 包装器；包装器首次运行时执行
`mise use -g <package>`，再以 `mise x` 启动工具。

因此 Omarchy 的 Node 默认值、开发环境菜单和 AI 懒加载命令都会写入并
依赖 `~/.config/mise/config.toml`。chezmoi 若覆盖这个文件，会删除 Omarchy
刚写入的全局选择；已经安装的 Node/Codex 随后也可能因“没有已选择版本”而
无法通过 shim 启动。

来源：

- <https://omarchy.org/manual/development-tools/>
- <https://omarchy.org/manual/ai/>
- <https://github.com/basecamp/omarchy/blob/v4.0.0/install/user/mise-work.sh>
- <https://github.com/basecamp/omarchy/blob/v4.0.0/bin/omarchy-mise-install>

### mise 的可叠加配置

mise 会始终读取全局 `~/.config/mise/config.toml`。设置
`MISE_ENV=dotfiles` 后，它还会读取同目录的 `config.dotfiles.toml` 并合并；
更具体的项目配置继续覆盖全局配置。`mise use -g` 的普通写操作仍以基础
`config.toml` 为目标，除非显式指定环境。

来源：

- <https://mise.jdx.dev/configuration/environments.html>
- <https://mise.jdx.dev/configuration.html>
- <https://mise.jdx.dev/dev-tools/shims.html>

## 采用的所有权边界

| 内容 | Omarchy | macOS/其他 Linux |
| --- | --- | --- |
| 账户 shell | Bash | 保持系统默认策略 |
| 交互 shell | Bash 防递归 `exec zsh` | zsh |
| `config.toml` | chezmoi 管理，条件排除系统工具 | chezmoi 管理 |
| `config.development.toml` | 项目需要时显式启用 | 保持当前全局启用 |
| Node 与 Omarchy AI CLI | 按需由 Omarchy/mise 写入；chezmoi 应用会恢复声明式配置 | chezmoi/mise 管理 |
| Arch 已提供的 CLI | pacman/Omarchy 管理 | 按现有策略管理 |

Omarchy 上的 mise 基础配置只声明系统包未提供的个人工具，例如 `dust`、
`shellcheck` 和 `lemonade`。不再由 mise 重复声明 `bat`、`fd`、`neovim`、
`rg`、`usage`，避免 shim 抢在 `/usr/bin` 前面改变 Omarchy 默认。
Omarchy 的 Codex 懒加载包装器会执行 `mise use -g codex`，因此在 Omarchy
分支中保留 `codex = "latest"`，避免每次运行后产生 chezmoi 配置漂移。

不要在 Omarchy 全局设置 `MISE_ENV=development`。当前开发配置声明 Node
LTS、Ruby 3.1.2、两套 Python 和 Go latest，会整体覆盖 Omarchy 的 Node
latest 策略并触发大量无关安装。版本敏感的非交互任务应使用项目自己的
`mise.toml`，或显式运行 `mise exec -- <command>`。

## 实现范围

实现保持最小变更：

1. 在 `dot_config/mise/config.toml.tmpl` 中，仅当
   `osRelease.id == "omarchy"` 时省略 pacman 已提供的重叠工具。
   同一分支保留 Omarchy 懒加载包装器动态登记的 Codex。
2. 保留现有 `MISE_ENV` 策略：macOS 全局启用 `development`，Omarchy 不
   全局启用开发运行时集合。
3. 保留现有 Bash 到 zsh 的防递归启动与 `env-bootstrap` 加载，不安装
   `omarchy-zsh` 的模板，避免它覆盖 chezmoi 管理的 `.bashrc/.zshrc`。
4. 应用后验证 Omarchy 使用 `/usr/bin/{bat,fd,nvim,rg,usage}`，同时 mise
   仍能解析 `dust`、`shellcheck` 和 `lemonade`。

该方案选择声明式 chezmoi 配置；Omarchy 命令临时写入 `config.toml` 的未声明
工具版本可能在下次 `chezmoi apply` 时被移除，需要的工具应加入 chezmoi
模板或项目级 `mise.toml`。
