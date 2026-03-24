---
name: handoff
description: generate a structured handoff summary for the next ai agent when context is long or session is ending. use when the user wants to continue work in a new session and needs a concise but complete transfer of state, progress, decisions, and next steps.
---

# write handoff summary

when the user indicates that the current context is too long, or wants to continue in a new session, generate a handoff document for another ai agent.

assume the next agent has no access to previous conversation history. the output must be self-contained and sufficient to resume work immediately.

## output format

write the result as a markdown document saved to:

./{yymmdd}-{hhmm}-handoff.md

use the following structure exactly:

## 1. 当前任务目标
clearly state the problem being solved, expected output, and completion criteria.

## 2. 当前进展
summarize completed analysis, decisions, changes, debugging, or discussions.

## 3. 关键上下文
include only actionable context:
- important background
- explicit user requirements
- constraints
- key decisions
- important assumptions

## 4. 关键发现
list the most important findings:
- conclusions
- patterns
- anomalies
- root causes
- design decisions

## 5. 未完成事项
list remaining work, sorted by priority.

## 6. 建议接手路径
tell the next agent how to proceed:
- what to inspect first (files, modules, logs, commands, etc.)
- what to validate
- recommended next actions

## 7. 风险与注意事项
highlight:
- common pitfalls
- already-tested dead ends
- things likely to cause duplicate work or confusion

## writing rules

- this is a handoff document, not a user-facing summary
- prioritize concrete, executable information
- avoid vague or generic statements
- reference real entities when possible (file paths, modules, commands, etc.)
- keep it dense and useful
- no fluff

## final requirement

end with:

“下一位 Agent 的第一步建议”

provide a clear first action the next agent should take.
