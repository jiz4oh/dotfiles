_ARCH=$(arch)

if [[ "$_ARCH" == "i386" ]]; then
 export BREW_PREFIX="/usr/local"
elif [[ "$_ARCH" == "arm64" ]]; then
 export BREW_PREFIX="/opt/homebrew"
fi

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export EDITOR=vim

export GPG_TTY=$(tty)
export RUBY_BUILD_MIRROR_URL=https://cache.ruby-china.com

export ASDF_GEM_DEFAULT_PACKAGES_FILE=~/.rbenv/default-gems
export YAMLLINT_CONFIG_FILE=~/.yamllint.yaml
