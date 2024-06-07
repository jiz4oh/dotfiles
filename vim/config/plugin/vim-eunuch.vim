" https://github.com/tpope/vim-eunuch/issues/56#issuecomment-626665562
if has('nvim') && get(g:, 'is_darwin', has('mac')) && $SUDO_ASKPASS == ""
  let $SUDO_ASKPASS = expand("~/bin/macos-askpass")
endif
