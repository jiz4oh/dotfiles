# https://zsh.sourceforge.io/Guide/zshguide02.html#l24
typeset -U PATH path
_ARCH=$(arch)

case $(uname -s) in
  "Darwin")
    if [[ "$_ARCH" == "i386" ]]; then
      export BREW_PREFIX="/usr/local"
    elif [[ "$_ARCH" == "arm64" ]]; then
      export BREW_PREFIX="/opt/homebrew"
    fi
    ;;
  "Linux")
    export BREW_PREFIX="/home/linuxbrew/.linuxbrew"
    ;;
esac

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [ -n "$NVIM" ]; then
  export EDITOR=nvim
else
  export EDITOR=vim
fi

export GPG_TTY=$(tty)
export RUBY_BUILD_MIRROR_URL=https://cache.ruby-china.com

export ASDF_GEM_DEFAULT_PACKAGES_FILE=~/.rbenv/default-gems
export ASDF_GOLANG_MOD_VERSION_ENABLED=true
export ASDF_DIRENV_IGNORE_MISSING_PLUGINS=1

export YAMLLINT_CONFIG_FILE=~/.yamllint.yaml

export HOMEBREW_NO_AUTO_UPDATE=1

# http://blog.joncairns.com/2013/12/understanding-ssh-agent-and-ssh-add/
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval $(ssh-agent) > /dev/null
fi
