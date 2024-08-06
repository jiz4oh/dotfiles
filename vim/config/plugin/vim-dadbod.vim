if !empty(getenv('USER'))
  let user = getenv('USER')
elseif !empty(getenv('USERNAME'))
  let user = getenv('USERNAME')
else
  let user = 'postgres'
end
let g:db = "postgresql://" . getenv('USER') . ":@localhost/postgres"

" https://habamax.github.io/2019/09/02/use-vim-dadbod-to-query-databases.html
xnoremap <expr> <Plug>(DBExe)     db#op_exec()
nnoremap <expr> <Plug>(DBExe)     db#op_exec()
nnoremap <expr> <Plug>(DBExeLine) db#op_exec() . '_'

function! s:init() abort
  xmap <buffer><leader>db  <Plug>(DBExe)
  nmap <buffer><leader>db  <Plug>(DBExe)
  omap <buffer><leader>db  <Plug>(DBExe)
  nmap <buffer><leader>dbb <Plug>(DBExeLine)
endfunction

function! s:init_sqlite() abort
  if executable('file') && executable('file')
    let path = expand('%:p')
    let output = system('file ' . path)
    if output =~# 'SQLite'
      let b:start = ':DB'
      execute 'DB b:db = sqlite:' . path
      let g:dbs = get(g:, 'dbs', {})
      let g:dbs[pathshorten(path)] = b:db
    endif
  endif
  call s:init()
endfunction

augroup vim-dadbod-augroup
  autocmd!

  autocmd FileType mysql,sql,plsql let b:start = ':DB' |
        \ let b:dispatch = ':DB' |
        \ call s:init()

  autocmd BufRead,BufNewFile *.db,*.sqlite3 call <SID>init_sqlite()
augroup END

function! s:pg_dump(with_data) abort
  if exists('b:db')
    let h = db#url#parse(b:db)
    let host = get(h, 'host', 'localhost')
    let port = get(h, 'port', '5432')
    let user = get(h, 'user', 'postgres')
    let database = get(h, 'path', '/postgres')
    let scheme = get(h, 'schema')
    if scheme ==# 'postgresql' || scheme ==# 'postgres'
      if a:with_data
        let command = 'pg_dump'
      else
        let command = 'pg_dump -s'
      end
      let command = command . ' -h ' . host . ' -U ' . user . ' ' . database[1:] . ' > schema.sql'  
      exec 'Echo ' . 'dadbod: ' . command
      call system(command)
    end
  end
endfunction

if executable('pg_dump')
  command! -bang PgDump call <SID>pg_dump(<bang>0)
end
