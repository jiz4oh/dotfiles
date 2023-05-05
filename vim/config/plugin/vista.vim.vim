let g:vista_sidebar_width = 35
let g:vista_executive_for = {
    \ 'vimwiki': 'markdown',
    \ 'pandoc': 'markdown',
    \ 'markdown': 'toc',
    \ }

let g:vista_ctags_cmd = {}
if executable('ripper-tags')
  let g:vista_ctags_cmd.ruby = 'ripper-tags --fields=+ln -f -'
  let g:vista#types#uctags#ruby# = {
      \ 'lang': 'ruby',
      \ 'sro': '.',
      \ 'kinds'      : {
        \ 'm': {'long' : 'modules',           'fold' : 0, 'stl' : 1},
        \ 'c': {'long' : 'classes',           'fold' : 0, 'stl' : 1},
        \ 'C': {'long' : 'constants',         'fold' : 0, 'stl' : 1},
        \ 'f': {'long' : 'methods',           'fold' : 0, 'stl' : 1},
        \ 'F': {'long' : 'singleton methods', 'fold' : 0, 'stl' : 1},
        \ 'a': {'long' : 'aliases',           'fold' : 0, 'stl' : 1},
        \},
      \ 'kind2scope' : {
        \ 'c' : 'class',
        \ 'f' : 'method',
        \ 'm' : 'module'
        \},
      \ 'scope2kind' : { 
        \ 'class'  : 'c',
        \ 'method' : 'f',
        \ 'module' : 'm'
        \},
      \ }
endif

if executable('gotags')
  let g:vista_ctags_cmd.go = 'gotags -sort -silent -f -'
endif

if exists('*nvim_open_win') || exists('*popup_create')
  let g:vista_echo_cursor_strategy = 'floating_win'
endif

nmap <silent> <Plug><OutlineToggle> :Vista!!<CR>
imap <silent> <Plug><OutlineToggle> <c-o>:Vista!!<CR>
