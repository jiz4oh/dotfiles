# AGENTS 可选片段库

这个文件是片段库。只抽取当前仓库真正需要的章节。

## 最小骨架

```md
# Agent 工作说明

## 包管理器
- 使用 `pnpm`：`pnpm install`、`pnpm dev`

## 文件级命令
| 任务 | 命令 |
|------|------|
| Lint | `pnpm eslint path/to/file.ts` |
| 测试 | `pnpm vitest path/to/spec.ts` |

## 关键约定
- 按 `CONTRIBUTING.md` 执行 setup 和 review 流程
- 参考 `src/routes/` 现有模式
```

## 可选 Frontmatter

未来 agent 需要稳定读取策略字段时再加入。

```yaml
---
last_reviewed: 2026-05-06
migration_policy: ask
commit_style: conventional
testing_policy: targeted_plus_related
public_api_policy: ask_first
monorepo_policy: mixed
agents_update_policy: propose_patch
---
```

## 可选策略章节

```md
## 已确认策略
- 迁移策略：执行 schema 或数据迁移前先确认
- 公共 API 策略：修改导出接口前先确认
- AGENTS 更新策略：仓库长期事实漂移时先提 patch
```

## 可选 Monorepo 章节

```md
## Monorepo 覆盖规则
- 根文件负责共享策略
- `packages/sdk/AGENTS.md` 负责导出 API 范围
- `apps/web/AGENTS.md` 负责本地应用命令
```

## 可选仓库地图

```md
## 仓库地图
- `apps/web`：主应用
- `packages/sdk`：导出 client 接口
- `packages/config`：共享工具配置
```

## 可选维护章节

```md
## AGENTS 维护
- 仓库证据变化时刷新事实型条目
- 文件保持在 `100` 行以内
```

## 注入规则

- 从最小骨架开始
- 每次只增加一个有依据的可选片段
- 每个片段都要能被仓库证据或已确认策略支撑

## 禁止注入

- `Co-Authored-By`
- `coauthor`
- `提交署名`
- 任何 commit trailer 模板

## 删除优先级

- 先删长段落背景
- 再删和 `README`、`CONTRIBUTING` 重复的说明
- 再删没有直接决策价值的目录清单
- 再删任何 coauthor 或提交署名相关内容
- 最后删没有证据支撑的可选章节
