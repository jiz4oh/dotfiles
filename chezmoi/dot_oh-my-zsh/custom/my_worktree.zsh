cwt() {
  local selected

  selected=$(
    git worktree list --porcelain |
      awk '/^worktree / {print substr($0, 10)}' |
      fzf --prompt='Worktree > ' \
          --height=40% \
          --reverse
  )

  [[ -n "$selected" ]] && builtin cd -- "$selected"
}

