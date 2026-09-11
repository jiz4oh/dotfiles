# handoff

Single self-contained cross-agent session handoff skill powered by the **CatchUp CLI**.

You do **not** need CatchUp's separate `SKILL.md`. This skill incorporates its useful workflow and adds the orchestration layer.

## Included

From CatchUp's official workflow:
- recap / find / handoff primitives
- `--since-compact`, `--last`, `--id`, list/search
- exact-session pinning
- materialize transcript once before reading
- 128 KiB size guardrail
- never silently truncate
- native fork vs clean `fork --into`

Added here:
- unified multi-agent chooser
- timestamps/title/cwd/ID/recent-intent presentation
- current-session exclusion
- source + target selection
- recover into the current already-open agent
- Git + `AGENTS.md` reconstruction
- filesystem-over-transcript evidence policy
- continue unfinished work after recovery

## Prerequisite

Install only the CatchUp CLI:

```bash
brew install wilbeibi/tap/catchup
```

Do not run `catchup install-skill` unless you intentionally want both skills.

## Install

Codex:

```bash
mkdir -p ~/.codex/skills
cp -R session-handoff ~/.codex/skills/session-handoff
```

Shared skills:

```bash
mkdir -p ~/.agents/skills
cp -R session-handoff ~/.agents/skills/session-handoff
```

Pi Agent:

```bash
mkdir -p ~/.pi/agent/skills
cp -R session-handoff ~/.pi/agent/skills/session-handoff
```

Claude Code:

```bash
mkdir -p ~/.claude/skills
cp -R session-handoff ~/.claude/skills/session-handoff
```

## Examples

- `接手之前的会话`
- `把刚才 Codex 的任务切到 Pi`
- `把昨天那个 Pi 会话接到当前 Codex`
- `A 已经没额度了，接手刚才那个 Codex`

The unavailable source model is never required to summarize or compact.
