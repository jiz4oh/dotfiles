cwt() {
  local selected

  selected=$(
    git worktree list --porcelain |
      awk '
        /^worktree / { path = substr($0, 10) }
        /^branch /   { ref = substr($0, 8); sub(/^refs\/heads\//, "", ref); printf "%s\t%s\n", ref, path }
        /^detached$/ { printf "%s\t%s\n", "(detached)", path }
      ' |
      fzf --prompt='Worktree > ' \
          --height=40% \
          --reverse \
          --delimiter='\t' \
          --with-nth=1
  )

  [[ -n "$selected" ]] && builtin cd -- "${selected#*$'\t'}"
}

