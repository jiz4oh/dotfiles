---
name: agent-extension-management
description: 在本 chezmoi 仓库中新增或调整 agent skill、原生 plugin 及其安装目标时使用，区分共享 skill 与 agent 私有 plugin。
---

# 管理 Agent 扩展

本仓库把两种扩展分开管理：

- 共享 skill：登记在 `chezmoi/.chezmoiexternals/skills.toml.tmpl`，由
  `scripts/install_skills` 链接到 `~/.agents/skills`。
- 原生 plugin：登记在 `chezmoi/.chezmoidata/plugins.toml`，由目标 agent 的
  原生命令安装。当前只实现 Codex adapter。

## 先判断类型

1. 只需要一个 `SKILL.md`，并希望 Codex、Claude Code、Gemini CLI、OpenCode
   等复用：只改 `skills.toml.tmpl`，给对应 external 增加 `x.skills`。
2. 需要 hooks、MCP、commands、应用连接或其他 agent 原生能力：只改
   `plugins.toml`，不要因为仓库里同时有 `skills/` 就创建共享 skill 链接。
3. 两者都需要：两个 registry 都显式登记，职责保持独立。

OpenViking 属于第 2 类：它的 Codex plugin 包含 hooks、MCP 和 bundled skills；
当前只安装 plugin，bundled skills 留在 plugin 私有目录。`ponytail` 同样只按
plugin 管理。`pua`、`superpowers` 等未登记 source 保持现状。

## 添加共享 skill

编辑 `chezmoi/.chezmoiexternals/skills.toml.tmpl`，优先复用已有 source：

```toml
[".agents/skill-sources/vendor"]
type = "git-repo"
url = "https://github.com/vendor/repo"
refreshPeriod = "72h"
clone.args = ["--filter=blob:none"]
pull.args = ["--ff-only"]
x.skills = ["skill-name=path/to/skill"]
```

`x.skills` 支持 `name=relative/path`；需要发现一个目录下的直接子 skill
时才使用 `*=relative/directory`。不要把 plugin marketplace 或
`plugin.json` 自动发现逻辑塞进 `install_skills`。

## 添加 Codex plugin

在 `chezmoi/.chezmoidata/plugins.toml` 增加一条记录：

```toml
[[plugins]]
agent = "codex"
marketplace = "vendor"
plugin = "plugin-name"
source = "https://github.com/vendor/repo.git"
ref = "main"
sparse_paths = ["path/to/marketplace", ".agents"]
shared_skills = []
```

`ref` 和 `sparse_paths` 按 marketplace 实际布局填写；没有 sparse checkout
需求时省略 `sparse_paths`。`shared_skills` 是意图记录，不会把 plugin 内置
skill 自动暴露到 `~/.agents/skills`；需要共享时，还要在 `skills.toml.tmpl`
中显式登记 source/path。

当前脚本支持 `agent = "codex"`，执行的原生命令等价于：

```sh
codex plugin marketplace add <source> [--ref <ref>] [--sparse <path> ...]
codex plugin marketplace upgrade <marketplace>
codex plugin add <plugin>@<marketplace>
```

脚本不会维护 `~/.agents/plugins/marketplace.json`，也不会纳入 OpenAI bundled
或 runtime plugin。其他 agent 可以先在同一 registry 增加记录；在增加对应
adapter 前，脚本会跳过并提示，不要假装已经完成安装。

包含 hooks 或 MCP 的 plugin 具备运行时副作用。添加前检查 manifest、信任提示、
凭据来源和目标 agent；`chezmoi apply` 会触发原生安装/刷新，真实执行前先看
dry-run 和 diff。

## 验证与交付

修改后运行：

```sh
scripts/install_plugins --dry-run
python3 scripts/test_install_plugins.py
scripts/install_skills
chezmoi --source "$PWD" managed
chezmoi --source "$PWD" apply --dry-run --force --no-tty
chezmoi --source "$PWD" diff
```

需要真正安装或刷新 plugin 时，再执行 `chezmoi apply --force --no-tty`，并用
以下命令确认 native state：

```sh
codex plugin marketplace list --json
codex plugin list --json
```

不要为了验证而执行 `codex plugin remove`、清理 cache 或删除未登记扩展。
