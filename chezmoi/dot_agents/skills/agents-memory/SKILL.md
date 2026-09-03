---
name: agents-memory
description: Maintain durable repository-local memory for future coding agents. Use before finishing meaningful engineering work that establishes reusable commands, architectural constraints, project conventions, verified gotchas, or resumable task state, and whenever an agents-memory hook requests a memory review.
---

# Agents Memory

Review what the task proved before finishing. Write only evidence-backed knowledge
that will change how a future agent works.

## Route each fact

- Put an always-relevant rule in the nearest `AGENTS.md`. Keep it short enough to
  justify loading on every task.
- Put architecture, boundaries, and stable project facts in
  `.agents/memory/context.md`.
- Put verified failure modes, failed approaches, and diagnostic shortcuts in
  `.agents/memory/bugs.md`.
- Put incomplete task state, evidence, blockers, and the exact next action in
  `.agents/memory/progress.md`. Replace or remove it when the state is resolved.

Use an existing project memory location when the repository already defines one.
Create `.agents/memory/` only when a qualifying fact has no existing home.

## Qualifying bar

Save a fact only when all are true:

- it was verified by source, configuration, commands, tests, or runtime evidence;
- it is non-obvious from a quick code search;
- it will remain useful beyond the current conversation;
- it has an actionable consequence for future work.

Current task state needs only the first and fourth conditions because it is
explicitly temporary.

Leave memory unchanged for routine file edits, conversation history, speculative
conclusions, transient debugging output, and facts likely to drift without a
cheap verification path.

## Update

1. Read the nearest agent instructions and existing memory before editing.
2. Compare each candidate fact with existing entries. Update or delete the
   authoritative entry instead of appending a duplicate.
3. Preserve unrelated work. Keep progress, durable facts, and agent rules
   distinct.
4. Review your memory diff against the qualifying bar. Remove memory-only churn
   introduced by this task.
5. Report which memory files changed and why, or state that nothing qualified.

The review is complete when every verified candidate fact is either routed to
one authoritative location or explicitly rejected by the qualifying bar.
