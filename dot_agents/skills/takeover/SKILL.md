---
name: takeover
description: read the latest handoff markdown, reconstruct execution state, and resume safely with minimal user re-explanation when user asks to continue prior work.
---

# Takeover From Handoff

When user asks to continue prior work, resume from handoff, or pick up previous context, locate handoff first.

## Scope

- In scope: locate handoff, load state, verify key facts quickly, continue execution.
- Out of scope: full historical replay, broad re-analysis before first action.

## File Selection

1. If user specified a handoff file, use it.
2. Else use newest match in current directory:
   - `./*-handoff.md`
3. If none found, state it clearly and ask for minimum missing context.

## Required Workflow (before new implementation work)

1. Read selected handoff fully.
2. Extract:
   - goal
   - completed work
   - pending items
   - risks and dead ends
   - first recommended action
3. Perform fast verification for high-impact claims (paths, changed files, running services, failing command).
4. Announce resume state briefly, then execute next action.

## Handoff Interpretation

Prioritize these sections:

- 当前任务目标
- 当前进展
- 关键上下文
- 关键发现
- 未完成事项
- 建议接手路径
- 风险与注意事项
- 下一位 Agent 的第一步建议

Use them to rebuild execution state and avoid duplicate work.

## Resume Message Pattern

After loading handoff, reply briefly:

1. `已加载 handoff: <filename>`
2. `正在继续: <task>`
3. `下一步: <single concrete action>`

Do not dump the full handoff unless user asks.

## Safety Rule (important)

- Do not delete handoff file by default.
- If cleanup is needed, move to archive path:
  - `./.handoff_archive/<original-name>`
- Only remove source file after archive copy is confirmed.

## Conflict and Missing Data Handling

- If handoff conflicts with latest user instruction, follow latest user instruction.
- If handoff is incomplete, ask one minimal clarification question.
- If claims cannot be verified quickly, mark as `待验证` and continue with bounded checks.

## Execution Rules

- Do not invent facts absent from handoff/workspace evidence.
- Do not redo completed work unless verification fails.
- Inspect referenced files/commands first before exploring new directions.
- Keep takeover summary concise and action-oriented.

## Quick Verification Commands

```bash
ls -lt ./*-handoff.md 2>/dev/null | head -n 5
rg -n "^## " ./$(ls -t ./*-handoff.md 2>/dev/null | head -n 1)
mkdir -p ./.handoff_archive
```

## Optional Archive Commands

```bash
f="$(ls -t ./*-handoff.md 2>/dev/null | head -n 1)"
[ -n "$f" ] && cp "$f" "./.handoff_archive/$(basename "$f")"
```
