augroup vim-dispatch-autocmd
  autocmd!
  
  autocmd BufNewFile,BufRead Dockerfile* let b:dispatch = 'docker build %:p:h -t %:p:h:t:gs/.*/\L&/:S'
  autocmd BufNewFile,BufRead docker-compose.yaml,docker-compose.yml let b:dispatch = 'docker compose -f %:p up -d'
  autocmd BufReadPost *
      \ if getline(1) =~# '^#!' |
      \   let b:dispatch = get(b:, 'dispatch',
      \       matchstr(getline(1), '#!\%(/usr/bin/env \+\)\=\zs.*') . ' %:p:S' ) |
      \   let b:start = get(b:, 'start', '-wait=always ' . b:dispatch) |
      \ endif
  autocmd FileType python let b:dispatch = 'python %:p:S'

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

  " https://github.com/tpope/vim-commentary/blob/f67e3e67ea516755005e6cccb178bc8439c6d402/plugin/commentary.vim#L16C1-L25C12
  function! s:strip_white_space(l,r,line) abort
    let [l, r] = [a:l, a:r]
    if l[-1:] ==# ' ' && stridx(a:line,l) == -1 && stridx(a:line,l[0:-2]) == 0
      let l = l[:-2]
    endif
    if r[0] ==# ' ' && (' ' . a:line)[-strlen(r)-1:] != r && a:line[-strlen(r):] == r[1:]
      let r = r[1:]
    endif
    return [l, r]
  endfunction

  function! s:uncomment_line(lnum1, lnum2) abort
    let [l, r] = split(get(b:, 'commentary_format', substitute(substitute(substitute(
        \ &commentstring, '^$', '%s', ''), '\S\zs%s',' %s', '') ,'%s\ze\S', '%s ', '')), '%s', 1)
    let uncomment = 2

    for lnum in range(a:lnum1,a:lnum2)
      let line = matchstr(getline(lnum),'\S.*\s\@<!')
      let [l, r] = s:strip_white_space(l,r,line)
      if len(line) && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
        return lnum
      endif
    endfor

    return 0
  endfunction

  autocmd BufReadPost *.go let line = <SID>uncomment_line(1, 20) |
        \ if line | let b:dispatch = 'go run ' . substitute(getline(line), 'package ', '', '') | endif
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
