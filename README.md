# dotfiles

这套配置使用 `chezmoi` 管理，仓库地址是 `https://github.com/jiz4oh/dotfiles.git`。

## 快速安装

### macOS

适用于新机器，假设还没有安装 Homebrew：

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/jiz4oh/dotfiles.git
```

这条命令会：

1. 安装 `chezmoi`
2. 拉取本仓库到 `~/.local/share/chezmoi`
3. 执行 `chezmoi apply`
4. 在首次 apply 时自动安装 Homebrew
5. 根据 [packages.yaml](/Users/jiz4oh/.local/share/chezmoi/chezmoi/.chezmoidata/packages.yaml) 安装 macOS 软件包

### Linux（Debian / Ubuntu / Arch / Omarchy）

完整包安装流程支持 Debian / Ubuntu 和基于 Arch 的 Omarchy：

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/jiz4oh/dotfiles.git
```

这条命令会：

1. 安装 `chezmoi`
2. 拉取本仓库到 `~/.local/share/chezmoi`
3. 执行 `chezmoi apply`
4. 在 Debian / Ubuntu 上自动执行 `apt` 包安装，在 Arch / Omarchy 上自动执行 `pacman` 包安装
5. 通过 `mise` 自动安装 `~/.config/mise/config.toml` 里声明的工具

## 分步安装

### macOS

```sh
sh -c "$(curl -fsLS get.chezmoi.io)"
~/.local/bin/chezmoi init https://github.com/jiz4oh/dotfiles.git
~/.local/bin/chezmoi apply --force --no-tty
```

如果 `chezmoi` 被安装到 `~/bin/chezmoi`，把上面的 `~/.local/bin/chezmoi` 改成 `~/bin/chezmoi`。

### Linux

```sh
sh -c "$(curl -fsLS get.chezmoi.io)"
~/.local/bin/chezmoi init https://github.com/jiz4oh/dotfiles.git
~/.local/bin/chezmoi apply --force --no-tty
```

## 常用命令

进入 source dir：

```sh
cd ~/.local/share/chezmoi
```

查看受管目标：

```sh
chezmoi --source "$PWD" managed
```

预览即将落盘的变更：

```sh
chezmoi --source "$PWD" diff
chezmoi --source "$PWD" apply --dry-run --force --no-tty
```

应用最新配置：

```sh
chezmoi update
```

## 常用目录跳转

Zsh 使用 zoxide 记录访问过的目录，通过现有 mise 配置安装。首次启用：

```sh
chezmoi apply ~/.config/mise/config.toml ~/.zshrc
mise install zoxide
```

打开新的 Zsh 终端后，先用 `cd` 访问项目，之后可以按关键词跳转：

```sh
z everymarket      # 跳转到匹配的常用目录
z work em          # 用多个关键词缩小范围
zi em              # 通过 fzf 选择目录；Esc 取消
```

`cd`、`AUTO_CD` 和现有 `ts` 用法保持不变。目录历史保存在本机，不通过 chezmoi 同步。

## 说明

- 包清单在 [chezmoi/.chezmoidata/packages.yaml](/Users/jiz4oh/.local/share/chezmoi/chezmoi/.chezmoidata/packages.yaml)。
- 外部依赖仓库由 [chezmoi/.chezmoiexternals/](/Users/jiz4oh/.local/share/chezmoi/chezmoi/.chezmoiexternals) 管理。
- 自动执行脚本在 [chezmoi/.chezmoiscripts/](/Users/jiz4oh/.local/share/chezmoi/chezmoi/.chezmoiscripts)。
- 仓库布局和迁移说明见 [chezmoi/CHEZMOI.md](/Users/jiz4oh/.local/share/chezmoi/chezmoi/CHEZMOI.md)。
