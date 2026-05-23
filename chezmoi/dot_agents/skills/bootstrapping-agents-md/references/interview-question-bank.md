# 采访问题库

只问当前还没有答案的策略问题。使用用户当前语言提问，每次一个问题，句子尽量短。仓库文档或当前 `AGENTS.md` 已经明确回答时直接跳过。

## 先不问规则

- 如果问题只决定可选章节是否存在，不影响最小骨架，直接省略该章节
- 如果问题只是为了把模板补完整，直接不问
- 如果仓库证据已经足够指导低风险事实型条目，直接记录为 `Inferred Repo Facts`
- 只有会改变策略字段、风险边界或章节结构的问题，才进入采访队列

## 推荐顺序

1. `migration_policy`
2. `commit_style`
3. `testing_policy`
4. `public_api_policy`
5. `monorepo_policy`
6. `agents_update_policy`

## 建议问题

### `migration_policy`

仓库里出现 `migrations`、`db/migrate`、`prisma/migrations`、`alembic`、`flyway`、`goose` 等信号时提问。

提问句式：

`迁移策略：auto / ask / never？`

记录值：

- `auto`
- `ask`
- `never`

推荐默认值：

- `ask`

### `commit_style`

git 历史和仓库文档还看不出明确风格时提问。

提问句式：

`提交风格：conventional / repo_native / freeform？`

记录值：

- `conventional`
- `repo_native`
- `freeform`

推荐默认值：

- `repo_native`

### `testing_policy`

测试入口很清楚时也建议提问，因为这代表风险边界。

提问句式：

`测试策略：targeted / targeted_plus_related / full_before_finish？`

记录值：

- `targeted`
- `targeted_plus_related`
- `full_before_finish`

推荐默认值：

- `targeted_plus_related`

### `public_api_policy`

仓库导出 library API、SDK surface、CLI contract、共享包边界时提问。

提问句式：

`公共 API 策略：allowed / ask_first / frozen？`

记录值：

- `allowed`
- `ask_first`
- `frozen`

推荐默认值：

- `ask_first`

### `monorepo_policy`

仓库里出现 workspace、`packages/*`、`apps/*`、`turbo.json`、`nx.json`、`rush.json` 或多个包根目录时提问。

提问句式：

`Monorepo 归属方式：root_owned / package_owned / mixed？`

记录值：

- `root_owned`
- `package_owned`
- `mixed`

推荐默认值：

- `mixed`

### `agents_update_policy`

用户希望把 AGENTS 维护方式一开始就固定下来时提问。

提问句式：

`AGENTS 更新方式：direct_patch / propose_patch / ask_first？`

记录值：

- `direct_patch`
- `propose_patch`
- `ask_first`

推荐默认值：

- `propose_patch`

## 追问规则

- 用户用自定义表述回答时，归一化到最近的记录值
- 回答里带环境例外时，把稳定默认值放进 frontmatter，把例外写进正文策略章节
- 仓库文档已经直接给出策略时，在工作笔记里记录证据，然后跳过提问
- 用户回答仍然模糊时，只允许再问一个缩窄问题
- 追问前先确认：这个问题如果不问，是否真的会改变最终 `AGENTS.md`

## 结束条件

- 剩余问题只影响可选章节时，可以直接结束采访
- 没有证据也没有确认来源的章节，保持省略
