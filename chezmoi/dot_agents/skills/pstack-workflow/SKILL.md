---
name: pstack-workflow
description: >
  Apply pstack engineering playbooks using the
  local agent roles, model routing, permissions,
  and repository policies.
---

# Pstack Workflow Adapter

## Source

Read upstream workflows from:

~/.agents/skill-sources/pstack/skills/

Read only the selected playbook and relevant
principles or supporting skills.

## Policy precedence

Repository instructions, global AGENTS.md,
agent permissions, and user authorization
take precedence over upstream workflows.

## Delegation

Use existing local agent roles:

- Investigation: explore
- Root-cause analysis: debugger
- Implementation: build / implementer
- Independent verification: reviewer
- Durable project knowledge: pcm

Use models configured by the harness.
Do not use upstream hardcoded model identifiers.

## Execution

- Select the smallest applicable playbook.
- Delegate only when it materially improves
  throughput or verification.
- Respect the existing Review Budget.
- Do not create redundant tests.
- Preserve the project issue tracker.
- Do not commit, push, merge, or deploy
  beyond the user's authorization.
- Use the existing handoff workflow
  for session continuation.

Do not invoke an unavailable agent or tool.
Adapt the workflow to the current harness.
