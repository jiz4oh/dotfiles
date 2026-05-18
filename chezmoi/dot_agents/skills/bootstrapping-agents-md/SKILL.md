---
name: bootstrapping-agents-md
description: 在进入缺少或过时 AGENTS.md 的仓库、需要通过仓库扫描加短采访生成首版 AGENTS.md、或需要对现有 AGENTS.md 做精简 patch 收敛时使用。触发词包括 AGENTS 初始化、AGENTS refine、repo 约束、monorepo 规则、采访用户、patch AGENTS。
---

# 初始化 AGENTS.md

## 使用时机

- 仓库里还没有 `AGENTS.md`
- 仓库里已经有 `AGENTS.md`，内容已经过时、过长、或信号密度偏低
- 用户希望把 agent 的工作习惯和项目约束沉淀下来
- 你发现了值得写入 `AGENTS.md` 的长期仓库事实

## 输出目标

- 生成或更新一个精简、可执行的 `AGENTS.md`
- 明确区分已确认策略和推断事实
- 只注入真正必要的可选章节
- 为后续 agent 留下稳定的 patch 基线

## 核心规则

- `AGENTS.md` 是 agent 在当前仓库的标准工作合同
- 目标控制在 `60` 行以内
- 硬上限控制在 `100` 行以内
- 使用标题、列表和简短代码块
- 只保留高信号的仓库事实和工作策略
- 明确禁止添加 `Co-Authored-By`、coauthor、提交署名章节
- 任何针对单一问题、单次事故或一次性修复的排障内容不得写入 `AGENTS.md`，必须写入独立文档（例如 `docs/` 下的 runbook/incident 记录）

## 决策优先级

- 用户当轮明确要求
- 已确认的仓库策略文档
- 现有 `AGENTS.md` 里仍然成立的策略
- 代码、配置、CI 给出的仓库事实
- 最后才使用启发式推断

## 工作流

### 1. 确定范围和现状

- 默认从仓库根目录工作，用户明确指定子包范围时按用户要求执行
- 先读取已有的 `AGENTS.md`、`CLAUDE.md`、`README*`、`CONTRIBUTING*` 和 CI 文件
- 产出：
  - 当前目标文件是根文件还是包级文件
  - 已经明确的策略清单
  - 需要删除的低信号内容候选

### 2. 扫描仓库事实

- 运行：
  ```bash
  python3 scripts/detect_repo_facts.py <repo-root> --markdown
  ```
- 对脚本输出里的异常结论做一次直接文件校验
- 产出：
  - 包管理器、命令、CI、公共 API、迁移、monorepo 证据
  - 建议采访主题

### 3. 决定要写哪些章节

- 从最小骨架开始
- 只有在仓库证据或已确认策略支撑时才注入可选章节
- 包级 `AGENTS.md` 只写本包真正覆盖根规则的部分
- 对工具链描述优先采用“当前实际生效”的管理器与配置（例如 `mise`、`config/mise`、`mise.toml`），不要因为历史残留文件（如 `.envrc` 中旧声明）回填过时结论
- 产出：
  - 保留章节
  - 删除章节
  - 需要采访确认的策略空白

### 4. 采访未解决的策略问题

- 只问当前证据无法回答的策略问题
- 一次只问一个问题
- 优先使用简短枚举选项
- 使用 [references/interview-question-bank.md](references/interview-question-bank.md)
- 当剩余问题只影响可选章节时，允许直接省略该章节
- 优先级顺序：
  - migration policy
  - commit style
  - testing policy
  - public API policy
  - monorepo ownership policy
  - AGENTS update policy

### 5. 生成首版或收敛 patch

- 默认生成最小版本文件
- `AGENTS.md` 里只放结构化内容
- 优先使用标题和项目列表
- 优先写文件级命令
- 通过现有文档和代码路径做引用
- linter 和 formatter 细节继续放在配置文件里
- 指令足够明确时直接落结论
- 文件只保留当前工作合同

### 6. 出口检查

- 行数是否仍在限制内
- 每个章节是否都有证据或确认来源
- 文件级命令是否真实可运行
- 策略字段是否只来自用户或明确文档
- patch 是否保持了原有用户策略
- 文件里是否完全没有 `Co-Authored-By`、coauthor、提交署名

## 冲突处理

- 文档和代码冲突时，先记录冲突，再问一个聚焦问题
- 根规则和包规则冲突时，包规则只覆盖本包范围
- 扫描不到足够证据时，保留最小骨架并减少章节
- 现有 `AGENTS.md` 过长时，优先删除背景段落、重复 setup、全量脚本列表

## 停止并确认

- 要修改策略字段时停下来问用户
- 要新增包级 `AGENTS.md` 时先确认范围是否值得拆分
- 要覆盖用户手写策略时先确认冲突如何裁决
- 要把高风险目录从“先确认”改成“可直接改”时先确认

## 默认章节

- `# Agent 工作说明`
- `## 包管理器`
- `## 文件级命令`
- `## 关键约定`

## 可选章节

仓库证据或已确认策略能支撑时再加入：

- frontmatter 机器可读策略块
- 迁移策略
- 公共 API 边界
- monorepo 覆盖规则
- 仓库地图
- AGENTS 维护规则
- CLI 或 API 模板片段

把 [references/agents-template.md](references/agents-template.md) 当作可选片段库使用，只注入当前仓库真正需要的部分。

## 禁止内容

- `Co-Authored-By`
- `coauthor`
- `提交署名`
- 和 commit trailer 相关的任何生成规则

## Monorepo 规则

- 根目录 `AGENTS.md` 负责共享策略
- 包级 `AGENTS.md` 负责本地命令和更严格边界
- 包级文件覆盖本包范围内的根规则

## 低信号内容

- 长背景介绍
- 和 `README` 或 `CONTRIBUTING` 重复的 setup 说明
- 所有脚本的完整罗列
- linter 和 formatter 的细碎风格规则
- 无证据支撑的架构评论
- 任何针对单一问题、单次事故或一次性修复的排障步骤（这类内容应写入独立文档，不进入 `AGENTS.md`）

## 持续收敛规则

- 使用 [references/refine-rules.md](references/refine-rules.md)
- 证据足够强时直接修补事实漂移
- 策略变化先问用户
- 使用尽量小的 diff 保持文件紧凑

## 测试提示

- `test-prompts.json` 保存典型评估场景
- 后续用 `darwin-skill` 优化时，优先跑这些场景

## 跨工具兼容

- 仓库同时依赖 `CLAUDE.md` 时，按仓库习惯创建或刷新 `CLAUDE.md -> AGENTS.md` 的符号链接
