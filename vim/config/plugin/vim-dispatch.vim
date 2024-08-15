augroup vim-dispatch-autocmd
  autocmd!
  
  autocmd BufNewFile,BufRead Dockerfile* let b:dispatch = get(b:, 'dispatch', 'docker build %:p:h -t %:p:h:t:gs/.*/\L&/:S')
  " https://docs.docker.com/compose/compose-application-model/#the-compose-file
  autocmd BufNewFile,BufRead compose.yaml,compose.yml,docker-compose.yaml,docker-compose.yml let b:dispatch = get(b:, 'dispatch', 'docker compose -f %:p up -d')
  autocmd BufReadPost *
      \ if getline(1) =~# '^#!' |
      \   let b:dispatch = get(b:, 'dispatch',
      \       matchstr(getline(1), '#!\%(/usr/bin/env \+\)\=\zs.*') . ' %:p:S' ) |
      \   let b:start = get(b:, 'start', '-wait=always ' . b:dispatch) |
      \ endif
  autocmd FileType zeroapi let b:dispatch = get(b:, 'dispatch', 'goctl api go --api %:p:S -dir %:p:h:S --style=go_zero')

  autocmd FileType python let b:dispatch = get(b:, 'dispatch', 'python %:p:S')
  if executable('ipython')
    autocmd FileType python let b:start = get(b:, 'start', 'ipython')
  else
    autocmd FileType python let b:start = get(b:, 'start', 'python')
  endif

  autocmd FileType ruby
        \ if !exists('b:rails_root') |
        \   let b:start = get(b:, 'start', 'irb -r %:p:S') |
        \   if expand('%') =~# '_spec\.rb$' |
        \     let b:dispatch = get(b:, 'dispatch', 'rspec %:s/$/\=exists("l#") ? ":".l# : ""/') |
        \   else |
        \     let b:dispatch = get(b:, 'dispatch', 'ruby %:p:S') |
        \   endif |
        \ endif

  autocmd FileType go let b:dispatch = get(b:, 'dispatch', 'go run %:p:S')
augroup END

function! s:console(bang) abort
  doautocmd User OpenConsolePre
  try
    let cmd = get(b:, 'console', get(b:, 'start', ''))
    if a:bang
      exec ':botright Start! ' . cmd
    else
      exec ':botright Start ' . cmd
    end
  finally
    doautocmd User OpenConsolePost
  endtry
endfunction

function! s:server(bang) abort
  doautocmd User OpenServerPre
  try
    let cmd = get(b:, 'server', get(b:, 'start', ''))
    if a:bang
      exec ':botright Start! ' . cmd
    else
      exec ':botright Start ' . cmd
    end
  finally
    doautocmd User OpenServerPost
  endtry
endfunction

command! -bang Console  :call <SID>console(<bang>0)
command! -bang Server   :call <SID>server(<bang>0)

xnoremap          `<CR>     :Dispatch<cr>
nnoremap          `<CR>     :Dispatch<cr>
xnoremap          m<space>  :Make
nnoremap          m<space>  :Make
nmap     <silent> '<CR>     :Start<CR>
nmap     <silent> '<leader> :Server<CR>
nmap     <silent> '\        :Console<CR>

let g:dispatch_no_maps = 1
let test#strategy = 'dispatch_background'

if !exists('g:dispatch_compilers')
  let g:dispatch_compilers = {}
endif

let g:dispatch_compilers = {
      \}
