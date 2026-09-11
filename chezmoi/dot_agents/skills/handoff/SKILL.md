---
name: handoff
description: Find, inspect, recover, resume, or transfer coding-agent sessions across Codex, Pi Agent, OpenCode, Claude Code, and other CatchUp-supported agents. Provides a unified cross-agent session chooser, exact-session pinning, safe transcript loading, current-agent recovery, clean/native fork selection, and Git/AGENTS.md state reconstruction. Use for requests such as "接手上一个会话", "继续之前的任务", "把刚才 Codex 切到 Pi", "把之前 Pi 的会话接到当前 Codex", or "resume the previous session here".
---

# Handoff

Use the local `catchup` CLI as the session compatibility layer. This skill is self-contained: **do not require CatchUp's separate agent skill**.

CatchUp owns native session parsing. This skill owns discovery, selection, transcript safety, handoff policy, project-state reconstruction, and continuation.

## Rules

1. Never silently choose among multiple plausible sessions.
2. Discover across all relevant CatchUp-supported agents unless the user constrained the source.
3. For multiple candidates, show a numbered chooser with agent, title, timestamps, cwd/project, short ID, recent user intent, and cwd match.
4. Exclude the current live/blank session when confidently identifiable; otherwise mark it `CURRENT?`.
5. Once selected, pin the source by stable ID whenever possible; never later fall back to "latest".
6. A dead/quota-exhausted source model must never be asked to summarize or compact.
7. If the target is the current already-open agent, read the selected transcript here; do not spawn another copy.
8. If the target is another/new agent, use CatchUp fork/handoff semantics.
9. Never silently truncate a large transcript.
10. Filesystem, tests, Git state, and applicable `AGENTS.md` outrank old conversational claims.
11. Never recover hidden reasoning, encrypted reasoning state, or chain-of-thought.
12. Do not merge multiple histories unless explicitly requested.

## Prerequisite

Verify:

```bash
command -v catchup >/dev/null 2>&1 && catchup --version
```

If missing, stop and recommend:

```bash
brew install wilbeibi/tap/catchup
```

Do **not** require `catchup install-skill`; this skill replaces it.

## CatchUp primitives

### Recap

```bash
catchup <agent> --since-compact
catchup <agent> --last 20
catchup <agent> --id <id>
```

### Find

```bash
catchup --list
catchup <agent> --list
catchup <agent> -q "<topic>"
catchup <agent>/<N>
catchup <agent> --id <id>
```

### Handoff

Typical semantics:

```bash
catchup fork <agent>
catchup fork <agent> --into <other-agent>
catchup fork <agent> --into <agent> --since-compact
```

Same-agent `fork` prefers native state. Cross-agent `fork --into` seeds a clean transcript. Same-agent `fork --into` with `--last`/`--since-compact` intentionally restarts clean.

Check the installed CatchUp version before relying on optional flags or exact-source fork syntax.

## Discover sessions

For an unqualified request, start with:

```bash
catchup --list
```

If constrained:

```bash
catchup codex --list
catchup pi-agent --list
catchup opencode --list
catchup claude --list
```

For a topic:

```bash
catchup <agent> -q "<topic>"
```

Do not parse native session stores manually unless CatchUp cannot satisfy the request and the user explicitly requests deeper recovery.

## Session chooser

If multiple plausible candidates exist, stop before loading/forking and show:

```text
[1] Codex · 修复 Sidekiq retry 行为
    Updated: 2026-09-11 10:32
    Started: 2026-09-11 09:48
    Project: ~/src/shop  [cwd match]
    ID: 01a08e42
    Last user: "继续检查 middleware ensure 中的 return..."

[2] Pi Agent · CPA auto-ping plugin
    Updated: 2026-09-10 21:18
    Project: ~/src/cpa-plugin
    ID: 7f31a9c2
    Last user: "build 后发布 GitHub Release..."
```

Title fallback: native name -> CatchUp title -> first meaningful user prompt -> latest meaningful user prompt -> `Untitled session`. Never invent a semantic title.

If the current newly-created target session appears, exclude it when confident; otherwise mark `[CURRENT?]` and require confirmation.

If constraints uniquely identify one session, proceed without a redundant chooser.

## Pin the source

Prefer:

```bash
catchup <source-agent> --id <session-id>
```

Use `<agent>/<N>` only when no stable ID exists. After selection, never use an unpinned "latest" command.

## Choose target

If not already specified, offer only available targets, distinguishing:

- Current agent session — absorb context here, no new process.
- New clean same-agent session — transcript-seeded clean restart.
- Native same-agent fork/resume — preserve native state.
- Different agent — transcript-seeded cross-agent handoff.

## Recover into the current agent

This is preferred when the user already opened the desired target, e.g. a new Codex App task on model B.

Do not spawn another CLI.

### Pin and materialize once

```bash
tmp="$(mktemp)"
catchup <source-agent> --id <session-id> --since-compact >"$tmp"
```

If `--since-compact` is empty/inappropriate, use a pinned `--last N` or full exact-session read.

Run CatchUp once into a temp file, then inspect/read that same file. This prevents a "latest session" race.

### Size guardrail

```bash
wc -c <"$tmp"
```

Use **128 KiB** as the default guardrail.

If <= 128 KiB, load it.

If > 128 KiB:
- never silently truncate;
- tell the user the size;
- offer full transcript or an explicit smaller slice such as `--last 20`;
- wait when the choice materially affects context.

If a smaller slice is chosen, materialize and measure that exact slice again.

### Reconstruct

Determine:
- current goal
- completed work
- accepted decisions
- rejected approaches
- files touched
- tests/checks run
- errors/blockers
- TODOs
- exact next action

Do not ask the dead source model to summarize.

## Handoff to another/new agent

Use CatchUp's fork/handoff functionality while preserving the exact selected source.

If the installed version supports exact-source fork directly, use it.

If it cannot safely combine exact-source selection with `fork --into`, do **not** silently fork the newest session. Explain the limitation and offer current-agent recovery or another exact-source transcript-seeding path supported by CatchUp.

Prefer native same-agent fork when the source still works and native state is useful.

Prefer clean transcript-seeded restart/handoff when:
- source model/provider is unavailable or quota exhausted;
- old compaction/model-specific state may be broken;
- crossing agent families;
- user requests a clean context.

For `Codex A unavailable -> Codex B`, prefer clean transcript-seeded B rather than native-resuming A state.

## Reconstruct project reality

When the selected session belongs to the current Git repo/worktree:

```bash
git branch --show-current
git status --short
git diff --stat
git diff
git diff --cached
git log -5 --oneline --decorate
```

Read applicable `AGENTS.md` files.

If the selected session has another cwd, do not attribute current-cwd Git state to it. Operate in the selected cwd when appropriate or state the mismatch.

Evidence priority:

```text
current files / working tree
> current tests/build/tool results
> Git state/history
> applicable AGENTS.md
> selected CatchUp transcript
> old summaries
```

## Continue

Unless the user only asked to list/inspect/transfer, recovery is not complete at a summary.

Briefly identify the recovered source and task, then continue from the next unfinished action without redoing completed work.

## Failures

- CatchUp missing: stop and provide CLI install command.
- No sessions: state cwd/filters; offer broader agent/topic/project search.
- Multiple recent sessions: show chooser; recency alone is insufficient.
- Current blank session newest: exclude if confident, else mark `CURRENT?`.
- Transcript >128 KiB: offer full vs explicit smaller slice; never silently shrink.
- `--since-compact` empty: use pinned `--last N` or full exact read.
- Git conflicts with transcript: trust repository reality.
- Target unavailable: keep source untouched and offer available targets/current recovery.
- Fork fails: keep source untouched, show concise error, offer current recovery/another target/reselection.

## Privacy

Keep discovery and reconstruction local. Do not print full transcripts unless requested or upload them to unrelated services. Transcripts can contain source code, prompts, paths, or credentials.

## Compatibility

Do not permanently hard-code supported agents. CatchUp currently covers agent families including Codex, Pi Agent, OpenCode, Claude Code, Cursor, Cline, Kimi, and Antigravity, but target capabilities can differ.

When uncertain:

```bash
catchup --help
catchup <agent> --help
catchup fork --help
```

Prefer installed behavior over assumptions in this file.
