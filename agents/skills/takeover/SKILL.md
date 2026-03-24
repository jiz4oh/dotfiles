---
name: takeover
description: read the latest handoff markdown file and resume work from it when the user starts a new session, asks to continue previous work, mentions handoff, or wants the agent to pick up from a saved transfer note. use when agent should inspect files like ./*-handoff.md, recover task state, summarize current status, and continue execution without access to the prior full conversation.
---

# takeover from handoff

when the user asks to continue previous work, resume from a prior session, read a handoff, or pick up from saved context, first look for the latest matching file in the current working directory:

./*-handoff.md

prefer the most recent file by date in the filename. if the user explicitly names a handoff file, use that file instead.

## required behavior

before doing any new task work:

1. locate the relevant handoff file
2. read it fully
3. extract the current task state from it
4. treat it as the primary source of prior-session context
5. continue from the handoff instead of asking the user to repeat background unnecessarily

## how to interpret the handoff

read the handoff as an execution-state document for another agent.

pay special attention to:

- 当前任务目标
- 当前进展
- 关键上下文
- 关键发现
- 未完成事项
- 建议接手路径
- 风险与注意事项
- 下一位 Agent 的第一步建议

use these sections to reconstruct:

- the actual goal
- what is already done
- what remains
- what has been ruled out
- what should be checked first
- what mistakes to avoid repeating

## response pattern after reading

after reading the handoff, do not dump the whole document back to the user.

instead:

- briefly acknowledge that the handoff has been loaded
- state the task you are resuming
- state the most relevant next action
- then continue the work

keep this brief unless the user explicitly asks for a full summary.

## when the handoff is missing or unclear

if no matching handoff file exists, say clearly that no handoff file was found in the current directory and continue by asking only for the minimum missing context.

if multiple handoff files exist and the latest one is ambiguous, prefer the newest dated filename unless the user specifies another file.

if the handoff conflicts with the user's new instruction, follow the user's latest instruction and treat the handoff as background context.

## execution rules

do not assume access to the old conversation.

do not invent missing facts that are not in the handoff.

do not restart completed work that the handoff says is already done unless verification is required.

do not ignore risks, dead ends, or rejected paths recorded in the handoff.

if the handoff includes concrete file paths, commands, modules, logs, or next steps, inspect those first before exploring new directions.

## preferred continuation behavior

when the handoff contains enough detail to proceed, start executing immediately.

when the handoff is incomplete, ask only the smallest possible follow-up question.

when the handoff recommends a first step, do that first unless the user's latest message overrides it.
