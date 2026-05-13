---
name: handoff
description: generate a structured, execution-ready handoff markdown for the next ai agent when context is long or the session is ending, with clear state, evidence, risks, and immediate next action.
---

# Write Handoff Summary

Use this skill when the user asks to continue in another session, requests handoff, or current context is too long.

Assume the next agent has no access to prior conversation. The handoff must be self-contained and immediately executable.

## Scope

- In scope: task state transfer, decisions, changed files, commands run, blockers, next action.
- Out of scope: rewriting implementation, speculative redesign, unrelated cleanup.

## Output File

Save markdown to:

`./{yymmdd}-{hhmm}-handoff.md`

Example: `./260513-1650-handoff.md`

## Required Workflow

1. Collect facts only from current workspace evidence:
   - changed files (`git status --short`)
   - key diffs (`git diff -- <file>`)
   - validation commands and outputs
   - unresolved errors and exact messages
2. Compress to execution state:
   - what is done
   - what remains
   - what was tried and ruled out
3. Write the handoff file in the required structure.
4. Run a quick self-check before finalizing.

## Required Structure

Use this structure exactly:

## 1. 当前任务目标
State problem, expected output, completion criteria.

## 2. 当前进展
Summarize completed analysis, decisions, code/config changes, debugging status.

## 3. 关键上下文
Include actionable background, hard constraints, user requirements, assumptions.

## 4. 关键发现
List conclusions, root causes, anomalies, rejected paths.

## 5. 未完成事项
Prioritized remaining work with dependency notes.

## 6. 建议接手路径
What to inspect first, what to run, what to validate.

## 7. 风险与注意事项
Pitfalls, risky operations, duplicate-work traps.

## 8. 证据与命令
Only include commands that were actually run or should be run first.

## Writing Rules

- Dense, executable, no fluff.
- Prefer concrete paths, modules, commands, and error strings.
- Mark unknowns explicitly as `不确定` and provide a verification path.
- Use absolute dates when time matters.

## Final Line (mandatory)

End with this heading and one concrete step:

`下一位 Agent 的第一步建议`

## Quick Verification

After writing the file, run:

```bash
ls -lt ./*-handoff.md | head -n 3
rg -n "^## (1|2|3|4|5|6|7|8)\\." ./*-handoff.md
rg -n "下一位 Agent 的第一步建议" ./*-handoff.md
```
