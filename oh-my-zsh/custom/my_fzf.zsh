pods() {
  FZF_DEFAULT_COMMAND='
    (echo CONTEXT NAMESPACE NAME READY STATUS RESTARTS AGE
     for context in $(kubectl config get-contexts --no-headers -o name | sort); do
       kubectl get pods --all-namespaces --no-headers --context "$context" | sed "s~^~${context} ~" &
     done; wait) 2> /dev/null | column -t
  ' fzf --info=inline --layout=reverse --header-lines=1 --border \
    --prompt 'pods> ' \
    --header $'╱ Enter (kubectl exec) ╱ CTRL-O (open log in editor) ╱ CTRL-R (reload) ╱\n\n' \
    --bind ctrl-/:toggle-preview \
    --bind 'enter:execute:kubectl exec -it --context {1} --namespace {2} {3} -- bash > /dev/tty' \
    --bind 'ctrl-o:execute:${EDITOR:-vim} <(kubectl logs --context {1} --namespace {2} {3}) > /dev/tty' \
    --bind 'ctrl-r:reload:eval "$FZF_DEFAULT_COMMAND"' \
    --preview-window up:follow \
    --preview 'kubectl logs --follow --tail=100000 --context {1} --namespace {2} {3}' "$@"
}

Rg() {
  local selected=$(
    rg --column --line-number --no-heading --color=always --smart-case "$1" |
      fzf --ansi \
          --delimiter : \
          --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
          --preview-window '~3:+{2}+3/2'
  )
  [ -n "$selected" ] && $EDITOR "$selected"
}

RG() {
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="$1"
  local selected=$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY' || true" \
      fzf --bind "change:reload:$RG_PREFIX {q} || true" \
          --ansi --disabled --query "$INITIAL_QUERY" \
          --delimiter : \
          --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
          --preview-window '~3:+{2}+3/2'
  )
  [ -n "$selected" ] && $EDITOR "$selected"
}
