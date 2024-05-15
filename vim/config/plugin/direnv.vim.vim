let g:direnv_auto = 0
" https://github.com/asdf-community/asdf-direnv?tab=readme-ov-file#pro-tips
" log breaks direnv.vim
let $DIRENV_LOG_FORMAT=""

augroup direnv_rc
  au!
  autocmd VimEnter * DirenvExport
  autocmd BufEnter * call direnv#extra_vimrc#check()
  " need this to avoid an error on loading
  autocmd User DirenvLoaded :

  if exists('##DirChanged')
    autocmd DirChanged * DirenvExport!
  else
    autocmd BufEnter * DirenvExport
  endif
augroup END
