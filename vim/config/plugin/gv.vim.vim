vnoremap <silent> <leader>gv :GV!<cr>
nnoremap <silent> <leader>gv :GV!<cr>
nnoremap <silent> <leader>gV :GV<cr>

function! s:gv_expand()
  let line = getline('.')
  GV --name-status
  call search('\V'.line, 'c')
  normal! zz
endfunction
autocmd! FileType GV nnoremap <buffer> <silent> + :call <sid>gv_expand()<cr>
