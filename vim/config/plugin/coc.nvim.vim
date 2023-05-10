let g:coc_global_extensions = [
      \'coc-json',
      \'coc-tag',
      \'coc-syntax',
      \]

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

inoremap <silent><expr> <C-y> coc#pum#visible() ? coc#pum#confirm() : "\<C-y>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:on_lsp_buffer_enabled() abort
  nnoremap <silent> <leader>ld <Plug>(coc-definition)
  nnoremap <silent> <leader>lD <Plug>(coc-declaration)
  nnoremap <silent> <leader>lt <Plug>(coc-type-definition)
  nnoremap <silent> <leader>li <Plug>(coc-implementation)
  nnoremap <silent> <leader>lr <Plug>(coc-references-used)
  nnoremap <silent> <leader>lR <Plug>(coc-rename)
  nnoremap <silent> <leader>lf <Plug>(coc-format-selected)
  xnoremap <silent> <leader>lf <Plug>(coc-format-selected)
  nnoremap <silent> <leader>ls :call CocActionAsync('documentSymbols')<cr>
  nnoremap <silent> <leader>lS :call CocActionAsync('getWorkspaceSymbols', '')<cr>
  nnoremap <silent> <leader>lK :call CocActionAsync('doHover')<cr>
  " nmap  <buffer><silent> <Plug><OutlineToggle> :call CocAction('showOutline')<CR>
  " imap  <buffer><silent> <Plug><OutlineToggle> <c-o>:<c-u>call CocAction('showOutline')<CR>

  let g:vista_{&filetype}_executive = 'coc'
  redraw | echomsg 'COC LSP attached'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

augroup coc_augoup
  autocmd!

  autocmd User CocStatusChange redrawstatus
  if !has('nvim') || get(g:, 'lsp_loaded', 0)
    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')
    autocmd User CocNvimInit ++once autocmd FileType * if CocHasProvider('definition') | call s:on_lsp_buffer_enabled() | endif
  endif
augroup END

