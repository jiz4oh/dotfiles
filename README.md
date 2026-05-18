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

### Linux

当前完整包安装流程主要针对 Debian / Ubuntu：

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/jiz4oh/dotfiles.git
```

这条命令会：

1. 安装 `chezmoi`
2. 拉取本仓库到 `~/.local/share/chezmoi`
3. 执行 `chezmoi apply`
4. 在 Debian / Ubuntu 上自动执行 `apt` 包安装

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

## 说明

- 包清单在 [chezmoi/.chezmoidata/packages.yaml](/Users/jiz4oh/.local/share/chezmoi/chezmoi/.chezmoidata/packages.yaml)。
- 外部依赖仓库由 [chezmoi/.chezmoiexternals/](/Users/jiz4oh/.local/share/chezmoi/chezmoi/.chezmoiexternals) 管理。
- 自动执行脚本在 [chezmoi/.chezmoiscripts/](/Users/jiz4oh/.local/share/chezmoi/chezmoi/.chezmoiscripts)。
- 仓库布局和迁移说明见 [chezmoi/CHEZMOI.md](/Users/jiz4oh/.local/share/chezmoi/chezmoi/CHEZMOI.md)。
