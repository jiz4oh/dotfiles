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
  `~/.config/{kitty,mise,rubocop,solargraph,wezterm}`、
  `~/.hammerspoon/{Spoons,modules}` 这类大目录，使用 symlink 管理
- 原先的 git submodule 现在统一放进 `chezmoi/.chezmoiexternals/`：
  `~/.config/kitty/kitty_search`、`~/.tmux/plugins/tpm`、以及
  `~/.agents/skill-sources/{git-commit-helper,notebooklm-skill,ordinary-claude-skills,superpowers}`
- Rime 上游仓库通过 external 落到 `~/.local/share/rime-frost`，本地覆盖层继续放在
  `rime/custom` 和 `rime/opencc`

## 脚本约定

会修改机器状态的步骤统一放在 `chezmoi/.chezmoiscripts/`：

- `run_once_*`：只执行一次的初始化步骤
- `run_onchange_*`：脚本内容变化时重新执行
- `run_after_*`：每次 `chezmoi apply` 完成后执行

## 包管理

声明式包清单放在 `chezmoi/.chezmoidata/`。当前唯一真源是：

```text
chezmoi/.chezmoidata/packages.yaml
```

对应安装脚本：

- macOS：`run_onchange_before_06_install_packages_darwin.sh.tmpl`
- Linux：`run_onchange_before_41_install_packages_linux.sh.tmpl`

## 手动脚本

不应该在 `chezmoi apply` 期间自动执行的 helper，继续放在
`.chezmoiscripts/` 之外。

Rime 这块的约定是：

- 用户手动入口保留在 `rime/`
- 只有自动同步钩子保留在 `chezmoi/.chezmoiscripts/`

## 备注

- `.chezmoiignore` 会忽略原始仓库文件，只让原生 `dot_*`、显式 `symlink_*`
  和脚本映射参与 apply
- 还在使用的 symlink 目标统一引用 `{{ .chezmoi.sourceDir }}`，这样 source dir
  挪位置后不用改路径
- 旧 `install` 脚本现在只适合做遗留的软件安装、插件安装或系统初始化补充，不再作为
  dotfiles 落盘主入口
- `oh-my-zsh/custom` 目前没有整体切成 symlink，因为很多机器已经有现成的
  Oh My Zsh 目录；后续要不要整体接管，先看目标机器的实际安装状态
