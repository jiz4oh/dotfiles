let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <m-H> :TmuxNavigateLeft<cr>
nnoremap <silent> <m-J> :TmuxNavigateDown<cr>
nnoremap <silent> <m-K> :TmuxNavigateUp<cr>
nnoremap <silent> <m-L> :TmuxNavigateRight<cr>
nnoremap <silent> <m-\> :TmuxNavigatePrevious<cr>

if has('nvim')  " Neovim
  tnoremap <silent> <m-H> <c-\><c-N>:TmuxNavigateLeft<cr>
  tnoremap <silent> <m-J> <c-\><c-N>:TmuxNavigateDown<cr>
  tnoremap <silent> <m-K> <c-\><c-N>:TmuxNavigateUp<cr>
  tnoremap <silent> <m-L> <c-\><c-N>:TmuxNavigateRight<cr>
  " Cannot use <c-\> here.
  " tnoremap <silent> <c-\> <c-\><c-n>:TmuxNavigatePrevious<cr>
endif
