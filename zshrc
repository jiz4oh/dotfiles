# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${xdg_cache_home:-$home/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${xdg_cache_home:-$home/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# What are the differences between a login shell and interactive shell?
# https://stackoverflow.com/a/18187389/12644334
# What should/shouldn't go in .zshenv, .zshrc, .zlogin, .zprofile, .zlogout?
# https://unix.stackexchange.com/a/71258
#
#
#
# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:/usr/local/bin:$PATH

[ -f $HOME/.zpath ] && source $HOME/.zpath
if [ $(command -v mise) ]; then
  # https://mise.jdx.dev/dev-tools/shims.html#zshrc-bashrc-files
  eval "$(mise activate zsh)"
fi
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
dotenv
git
gitignore
git-auto-fetch
kubectl
copybuffer
command-not-found
extract
safe-paste
fzf
tailscale
)

for plugin in fzf-tab \
  zsh-autosuggestions \
  zsh-syntax-highlighting; do
  if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin ]; then
    plugins+="$plugin"
  fi
done

source $ZSH/oh-my-zsh.sh

# ============================User configuration========================

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
###### Multiple Homebrew
PROMPT="$(arch) $PROMPT"

#export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"
# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
# ============================Compilation flags==========================
# export ARCHFLAGS="-arch x86_64"export LDFLAGS="-L$(brew --prefix libffi)/lib"
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run alias.
#

# ============================custom settings============================
setopt no_nomatch
setopt AUTO_CD

# ============================Example aliases============================
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

l.() {
  [ -z $1 ] && ls -lhd .* || ls -lhd $1/.*
}

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

kport () {
  kill -9 $(lsof -t -i :$1)
}

proxy () {
    export url=${1:=127.0.0.1} && export port=${2:=37890} && export https_proxy=http://$url:$port http_proxy=http://$url:$port all_proxy=socks5://$url:$port
    echo "Proxy on"
}

unproxy () {
    unset http_proxy
    unset https_proxy
    unset all_proxy
    echo "Proxy off"
}

# run 'zprof' to get profiling information
zmodload zsh/zprof

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
for file in $HOME/.p10k.zsh \
  $HOME/.zlocal \
  $HOME/.alias; do
  if test -f "$file"; then
    # 文件存在,执行source命令加载文件
    source "$file"
  fi
done

if [ $(command -v sgpt) ]; then
  # https://github.com/TheR1D/shell_gpt
  # Shell-GPT integration ZSH v0.2
  _sgpt_zsh() {
  if [[ -n "$BUFFER" ]]; then
      _sgpt_prev_cmd=$BUFFER
      BUFFER+="⌛"
      zle -I && zle redisplay
      BUFFER=$(sgpt --shell <<< "$_sgpt_prev_cmd" --no-interaction)
      zle end-of-line
  fi
  }
  zle -N _sgpt_zsh
  bindkey ^l _sgpt_zsh
  # Shell-GPT integration ZSH v0.2
fi
