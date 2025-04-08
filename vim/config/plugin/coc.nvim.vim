let g:coc_config_home = '~/.vim'
let g:coc_global_extensions = [
      \'coc-json',
      \'coc-tag',
      \'coc-syntax',
      \]

if exists('g:node_path')
  let g:coc_node_path = g:node_path
end

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
" inoremap <silent><expr> <TAB>
"       \ coc#pum#visible() ? coc#pum#next(1) :
"       \ CheckBackspace() ? "\<Tab>" :
"       \ coc#refresh()
" inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" " Make <CR> to accept selected completion item or notify coc.nvim to format
" " <C-g>u breaks current undo, please make your own choice.
" inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
"                               \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" inoremap <silent><expr> <C-y> coc#pum#visible() ? coc#pum#confirm() : "\<C-y>"

" Use <c-space> to trigger completion.
" if has('nvim')
"   inoremap <silent><expr> <c-space> coc#refresh()
" else
"   inoremap <silent><expr> <c-@> coc#refresh()
" endif

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:on_lsp_buffer_enabled() abort
  let b:coc_lsp_attached = 1
  " Highlight the symbol and its references when holding the cursor.
  autocmd coc_augoup CursorHold <buffer> * silent call CocActionAsync('highlight')

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
  redraw
  let msg = 'COC LSP attached'
  if has('nvim')
    call v:lua.vim.notify(msg)
  else
    echomsg msg
  end
endfunction

function! s:on_coc_float_opened() abort
  if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <buffer><silent><nowait><expr> <M-j> coc#float#has_scroll() ? coc#float#scroll(1) : "\<M-j>"
    nnoremap <buffer><silent><nowait><expr> <M-k> coc#float#has_scroll() ? coc#float#scroll(0) : "\<M-k>"
    inoremap <buffer><silent><nowait><expr> <M-j> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<M-j>"
    inoremap <buffer><silent><nowait><expr> <M-k> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<M-k>"
    vnoremap <buffer><silent><nowait><expr> <M-j> coc#float#has_scroll() ? coc#float#scroll(1) : "\<M-j>"
    vnoremap <buffer><silent><nowait><expr> <M-k> coc#float#has_scroll() ? coc#float#scroll(0) : "\<M-k>"
  endif
endfunction

augroup coc_augoup
  autocmd!

  autocmd User CocStatusChange redrawstatus
  if !get(g:, 'lspconfig', 0) && !get(g:, 'lsp_loaded', 0)
    function! s:try_lsp() abort
      try
        " CocHasProvider cause
        " E608: Cannot :throw exceptions with 'Vim' prefix
        let has_lsp = CocHasProvider('definition') && !get(b:, 'coc_lsp_attached', 0)
      catch
        let has_lsp = 0
      endtry

      if has_lsp
        call s:on_lsp_buffer_enabled()
      endif
    endfunction

    autocmd User CocNvimInit ++once autocmd FileType * call s:try_lsp()
    autocmd User CocOpenFloat call s:on_coc_float_opened()
  endif
augroup END

