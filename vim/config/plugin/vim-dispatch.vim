augroup vim-dispatch-autocmd
  autocmd!
  
  autocmd BufNewFile,BufRead Dockerfile* let b:dispatch = 'docker build %:p:h -t %:p:h:t:gs/.*/\L&/:S'
  " https://docs.docker.com/compose/compose-application-model/#the-compose-file
  autocmd BufNewFile,BufRead compose.yaml,compose.yml,docker-compose.yaml,docker-compose.yml let b:dispatch = 'docker compose -f %:p up -d'
  autocmd BufNewFile,BufRead requirements.txt let b:dispatch = 'pip install -r %'
  autocmd BufNewFile,BufRead yarn.lock let b:dispatch = 'yarn install'
  autocmd BufNewFile,BufRead pnpm-lock.yaml let b:dispatch = 'pnpm install'
  autocmd BufNewFile,BufRead package-lock.json let b:dispatch = 'npm install'
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

  if executable('air')
    autocmd BufReadPost *.go let b:dispatch = 'air'
  else
    autocmd BufReadPost *.go let b:dispatch = 'go run %:p:S'
  end
  autocmd BufReadPost pyproject.toml if executable('pdm') |
        \ let b:dispatch = 'pdm install -p %:p:h:S'|
        \ endif
augroup END

xnoremap `<CR>             :Dispatch<cr>
nnoremap `<CR>             :Dispatch<cr>
xnoremap m<space>          :Make 
nnoremap m<space>          :Make 

let g:dispatch_no_maps = 1
let test#strategy = 'dispatch_background'

if !exists('g:dispatch_compilers')
  let g:dispatch_compilers = {}
endif

let g:dispatch_compilers = {
      \}
