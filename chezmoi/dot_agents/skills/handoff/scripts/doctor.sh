#!/usr/bin/env bash
set -euo pipefail

printf 'session-handoff doctor\n\n'

if command -v catchup >/dev/null 2>&1; then
  printf '[ok] catchup: %s\n' "$(command -v catchup)"
  catchup --version 2>/dev/null || true
else
  printf '[missing] catchup\n'
  printf 'Install: brew install wilbeibi/tap/catchup\n'
fi

printf '\nAgent executables:\n'
for cmd in codex pi opencode claude; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[ok] %-10s %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '[--] %-10s not found in PATH\n' "$cmd"
  fi
done

printf '\nGit context:\n'
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf '[ok] git repository: %s\n' "$(git rev-parse --show-toplevel)"
  printf 'branch: %s\n' "$(git branch --show-current)"
  git status --short || true
else
  printf '[--] current directory is not a git repository\n'
fi
