nmap <silent> <leader>tr :TestNearest<CR>
nmap <silent> <leader>tf :TestFile<CR>
nmap <silent> <leader>ta :TestSuite<CR>
nmap <silent> <leader>tl :TestLast<CR>

augroup vim-test-augroup
  autocmd!

  autocmd User ProjectionistActivate let g:test#project_root = projectionist#path()
augroup END
