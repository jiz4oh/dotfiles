" https://github.com/tpope/vim-eunuch/issues/56#issuecomment-626665562
if has('nvim') && get(g:, 'is_darwin', has('mac')) && $SUDO_ASKPASS == ""
  let path = expand("$HOME/.local/share/chezmoi/chezmoi/bin/macos-askpass")
  if filereadable(path)
    let $SUDO_ASKPASS = path
  endif
endif
