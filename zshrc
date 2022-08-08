# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="agnoster"

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
git
zsh-autosuggestions
zsh-syntax-highlighting
extract
safe-paste
)

source $ZSH/oh-my-zsh.sh
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export HOMEBREW_NO_AUTO_UPDATE=true

_ARCH=$(arch)
if [[ "$_ARCH" == "i386" ]]; then
 export PATH="/usr/local/bin:$PATH"
 export PATH="/usr/local/opt:$PATH"
elif [[ "$_ARCH" == "arm64" ]]; then
 # export GEM_HOME=$HOME/.gems
 export PATH="/opt/homebrew/bin:$PATH"
 export PATH="/opt/homebrew/opt:$PATH"
fi

export EDITOR=vim

export GPG_TTY=$(tty)
# export PATH="$(brew --prefix helm@2)/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export RUBY_BUILD_MIRROR_URL=https://cache.ruby-china.com

# ============================Example aliases============================
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# macos
alias abrew="/opt/homebrew/bin/brew"
alias i="arch -x86_64"
alias i="arch -x86_64"
alias ibrew="arch -x86_64 /usr/local/bin/brew"

# unix
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias cd.='cd ..'
alias cd..='cd ..'
alias l.='ls -lhd .*'
alias l='ls -alF'
alias ll='ls -l'

# software
alias vi=$EDITOR
alias vimdiff='nvim -d'
alias k=kubectl

[ -f $HOME/.zprofile ] && source $HOME/.zprofile
[ -f $HOME/.zlocal ] && source $HOME/.zlocal

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(rbenv init -)"

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

new_wechat() {
  nohup /Applications/WeChat.app/Contents/MacOS/WeChat > /dev/null 2>&1 &
}
