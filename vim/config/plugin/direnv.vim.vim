let g:direnv_auto = 0
" https://github.com/asdf-community/asdf-direnv?tab=readme-ov-file#pro-tips
" log breaks direnv.vim
let $DIRENV_LOG_FORMAT=""

augroup direnv_rc
  au!
  autocmd VimEnter * silent! DirenvExport
  autocmd BufEnter * if get(g:, 'loaded_direnv') | call direnv#extra_vimrc#check() | endif
  " need this to avoid an error on loading
  autocmd User DirenvLoaded :

  if exists('##DirChanged')
    autocmd DirChanged * silent! DirenvExport!
  else
    autocmd BufEnter * silent! DirenvExport
  endif
augroup END
