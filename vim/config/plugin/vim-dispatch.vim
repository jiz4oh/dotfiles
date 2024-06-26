augroup vim-dispatch-autocmd
  autocmd!
  
  autocmd BufNewFile,BufRead Dockerfile* let b:dispatch = 'docker build %:p:h -t %:p:h:t:gs/.*/\L&/:S'
  " https://docs.docker.com/compose/compose-application-model/#the-compose-file
  autocmd BufNewFile,BufRead compose.yaml,compose.yml,docker-compose.yaml,docker-compose.yml let b:dispatch = 'docker compose -f %:p up -d'
  autocmd BufReadPost *
      \ if getline(1) =~# '^#!' |
      \   let b:dispatch = get(b:, 'dispatch',
      \       matchstr(getline(1), '#!\%(/usr/bin/env \+\)\=\zs.*') . ' %:p:S' ) |
      \   let b:start = get(b:, 'start', '-wait=always ' . b:dispatch) |
      \ endif
  autocmd FileType python let b:dispatch = 'python %:p:S'
  autocmd FileType zeroapi let b:dispatch = 'goctl api go --api %:p:S -dir %:p:h:S --style=go_zero'

  if executable('ipython')
    autocmd FileType python let b:start = 'ipython'
  else
    autocmd FileType python let b:start = 'python'
  endif

  autocmd FileType ruby
        \ if !exists('b:rails_root') && !exists('b:start') |
        \   let b:start = 'irb -r %:p:S' |
        \ endif |
        \ if exists('b:rails_root') || exists('b:dispatch') |
        \ elseif expand('%') =~# '_spec\.rb$' |
        \   let b:dispatch = get(b:, 'dispatch', 'rspec %:s/$/\=exists("l#") ? ":".l# : ""/') |
        \ elseif !exists('b:dispatch') |
        \   let b:dispatch = 'ruby %:p:S' |
        \ endif

  autocmd BufReadPost *.go let b:dispatch = 'go run %:p:h:S'
augroup END

xnoremap `!                :Dispatch!
xnoremap `<CR>             :Dispatch<cr>
xnoremap m<CR>             :Make<cr>
xnoremap g'!               :Spawn!
xnoremap g'<CR>            :Spawn<cr>
nnoremap <leader>t'<space> :tab Start<space>
nnoremap <leader>t'<CR>    :tab Start<cr>

let test#strategy = 'dispatch_background'

if !exists('g:dispatch_compilers')
  let g:dispatch_compilers = {}
endif

let g:dispatch_compilers = {
      \}
