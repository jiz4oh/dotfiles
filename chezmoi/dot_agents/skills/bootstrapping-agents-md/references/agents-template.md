# AGENTS 可选片段库

这个文件是片段库。默认只生成最小骨架；只有在证据足够、而且该片段能帮助未来 agent 决策时，才注入对应章节。

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

## 精准修改
- 只碰必须碰的；只清理自己造成的混乱
- 不要顺手“改进”相邻代码、注释、格式或措辞
- 不要重构没坏的内容
- 优先匹配现有仓库风格
- 只删除因本次改动而变成孤儿的内容
- 预先存在的死代码先指出，不主动删除
- 每一行修改都要能追溯到当前请求或已确认事实
```

## 可选 Frontmatter

触发条件：

- 未来 agent 需要稳定读取策略字段
- 对应字段已经来自用户确认或明确文档
- 这些字段会影响后续 patch 或执行决策

省略条件：

- 只是为了补全模板
- 字段目前仍属于待确认偏好

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

触发条件：

- 用户明确确认了策略值
- 或现有仓库文档已经写明策略边界
- 这些策略会影响高风险决策

```md
## 已确认策略
- 迁移策略：执行 schema 或数据迁移前先确认
- 公共 API 策略：修改导出接口前先确认
- AGENTS 更新策略：仓库长期事实漂移时先提 patch
```

## 可选 Monorepo 章节

触发条件：

- 仓库已经被确认是 monorepo
- 根规则和包规则的覆盖关系需要显式说明
- 不写这一节会让未来 agent 误把包级细节塞进根文件

```md
## Monorepo 覆盖规则
- 根文件负责共享策略
- `packages/sdk/AGENTS.md` 负责导出 API 范围
- `apps/web/AGENTS.md` 负责本地应用命令
```

## 可选仓库地图

触发条件：

- 仓库确实有多个高价值目录
- 这份地图会帮助定位命令、边界或职责
- 地图内容可以保持很短，不会挤占核心合同

省略条件：

- 只是目录罗列
- 和 `README` 的导航内容重复

```md
## 仓库地图
- `apps/web`：主应用
- `packages/sdk`：导出 client 接口
- `packages/config`：共享工具配置
```

## 可选维护章节

触发条件：

- 用户希望提前固定 AGENTS 维护方式
- 或仓库已经明确要求 agent 定期刷新事实型条目

```md
## AGENTS 维护
- 仓库证据变化时刷新事实型条目
- 文件保持在 `100` 行以内
```

## 注入规则

- 从最小骨架开始
- `精准修改` 属于默认章节，不要省略
- 每次只增加一个有依据的可选片段
- 每个片段都要能被仓库证据或已确认策略支撑
- 先写为什么要加，再决定是否真的加
- 如果片段只让模板更完整、却不帮助未来决策，就保持省略
- 不允许因为“模板里有这一节”就默认注入

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

## 使用提示

- 先列 `Confirmed Policies`、`Inferred Repo Facts`、`待确认`
- 只把前两类里真正有决策价值的内容写入 `AGENTS.md`
- `待确认` 里只要不影响最小骨架，就继续省略，不为补全模板提问
