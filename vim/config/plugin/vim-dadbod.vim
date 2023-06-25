let g:db = "postgresql://postgres:@localhost/postgres"

" https://habamax.github.io/2019/09/02/use-vim-dadbod-to-query-databases.html
xnoremap <expr> <Plug>(DBExe)     db#op_exec()
nnoremap <expr> <Plug>(DBExe)     db#op_exec()
nnoremap <expr> <Plug>(DBExeLine) db#op_exec() . '_'

xmap <leader>db  <Plug>(DBExe)
nmap <leader>db  <Plug>(DBExe)
omap <leader>db  <Plug>(DBExe)
nmap <leader>dbb <Plug>(DBExeLine)

function! s:init_sqlite() abort
  if executable('file')
    let path = expand('%:p')
    let output = system('file ' . path)
    if output =~# 'SQLite'
      let b:start = ':DB'
      execute 'DB b:db = sqlite:' . path
    endif
  endif
endfunction

augroup vim-dadbod-augroup
  autocmd!

  autocmd FileType mysql,sql,plsql let b:start = ':DB' |
        \ let b:dispatch = ':DB'

  autocmd BufRead,BufNewFile *.db call <SID>init_sqlite()
augroup END
