" turn on case-insensitive feature
let g:EasyMotion_smartcase  = 1

map <Leader><Leader> <Plug>(easymotion-prefix)
" " move to line
" nmap <leader><leader>f <Plug>(easymotion-overwin-f)
" xmap <leader><leader>f <Plug>(easymotion-bd-f)
" omap <leader><leader>f <Plug>(easymotion-bd-f)

" nmap <leader><leader>w <Plug>(easymotion-overwin-w)
" xmap <leader><leader>w <Plug>(easymotion-bd-w)
" omap <leader><leader>w <Plug>(easymotion-bd-w)

map  gl <Plug>(easymotion-bd-jk)
nmap gl <Plug>(easymotion-overwin-line)

autocmd User EasyMotionPromptBegin :let b:coc_diagnostic_disable = 1
autocmd User EasyMotionPromptEnd :let b:coc_diagnostic_disable = 0
