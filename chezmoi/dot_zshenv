# https://zsh.sourceforge.io/Guide/zshguide02.html#l24
typeset -U PATH path

[ -f $HOME/.shenv ] && source $HOME/.shenv

# load zpath in non-login non-interactive shell
if [[ $- != *i* ]]; then
  if [[ $- != *l* ]]; then
    [ -f $HOME/.zpath ] && source $HOME/.zpath
  fi
fi

# 1. login interactive shell:
#   -	/etc/zshenv
#   -	~/.zshenv
#   -	/etc/zprofile # macos path_helper
#   -	~/.zprofile
#   -	~/.zlogin
#   - ~/.zshrc
# 2. login non-interactive shell: (usually open new shell in current shell)
#   -	/etc/zshenv
#   -	~/.zshenv
#   - /etc/zprofile # macos path_helper
# 	- ~/.zprofile
# 3. non-login interactive shell:
#   -	/etc/zshenv
#   -	~/.zshenv
#   -	~/.zshrc
# 4. non-login non-interactive shell:
#   -	/etc/zshenv
#   -	~/.zshenv
