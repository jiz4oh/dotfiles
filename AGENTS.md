# Agent 工作说明

## 包管理器

- 主入口是 `chezmoi`；仓库根目录就是 source dir。
- 包清单在 `chezmoi/.chezmoidata/packages.yaml`。
- 外部依赖仓库由 `chezmoi/.chezmoiexternals/` 目录管理。

## 文件级命令

```sh
chezmoi --source "$PWD" managed
chezmoi --source "$PWD" apply --dry-run --force --no-tty
chezmoi --source "$PWD" apply --force --no-tty
```

- 查看待应用差异时运行 `chezmoi --source "$PWD" diff`。
- 改 `chezmoi/.chezmoidata/*`、`chezmoi/.chezmoiexternals/*`、`chezmoi/.chezmoiscripts/*`、`chezmoi/dot_*` 后，至少运行 `chezmoi --source "$PWD" managed` 和 `chezmoi --source "$PWD" apply --dry-run --force --no-tty`。
- 改会影响落盘结果的模板或映射后，再跑一次 `chezmoi --source "$PWD" diff` 确认变更范围。

## 关键约定

- 共享规则写在根 `AGENTS.md`；子目录里的 `AGENTS.md` 只覆盖本目录范围。
- 主要受管内容在 `chezmoi/`；机器级配置通常使用 `dot_*`、`symlink_*`、`run_*` 命名。
- `chezmoi/CHEZMOI.md` 是迁移和布局说明；大范围结构调整前先对照这里。
- 外部仓库优先通过 `.chezmoiexternals/` 目录管理，避免直接把第三方源码散落进受管目录。
- agent skill source repo 与暴露的 skill 入口统一登记在 `chezmoi/.chezmoiexternals/skills.toml`；`scripts/install_skills` 会读取各个 `.agents/skill-sources/*` entry 的 `x.skills`，执行后在本机 `$HOME/.agents/skills` 下生成软链接。
- 提交信息保持 `conventional commit` 风格，必要时加 scope；现有历史以 `feat(chezmoi): ...`、`fix(vim): ...` 为准。
- 有包级规则时先读最近的那个，例如 `chezmoi/AGENTS.md`、`codex/AGENTS.md`、`chezmoi/dot_agents/skills/wx-cli/AGENTS.md`。
- 不要在生成内容里加入 `Co-Authored-By`、`coauthor` 或提交署名规则。
