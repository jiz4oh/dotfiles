let g:lsp_document_highlight_enabled = 0
let g:lsp_format_sync_timeout = 1000

function! s:on_lsp_buffer_enabled() abort
    " folds slow down vim with large text
    command! -buffer LspEnableFold :setlocal foldmethod=expr
      \ foldexpr=lsp#ui#vim#folding#foldexpr()
      \ foldtext=lsp#ui#vim#folding#foldtext()

    command! -buffer LspDisableFold :setlocal foldmethod=expr
      \ foldexpr=lsp#ui#vim#folding#foldexpr()
      \ foldtext&vim

    setlocal omnifunc=lsp#complete
    nmap <buffer>         <leader>ld <plug>(lsp-definition)
    nmap <buffer>         <leader>lD <plug>(lsp-declaration)
    nmap <buffer>         <leader>lt <plug>(lsp-type-definition)
    nmap <buffer>         <leader>li <plug>(lsp-implementation)
    nmap <buffer>         <leader>lr <plug>(lsp-references)
    nmap <buffer>         <leader>lR <plug>(lsp-rename)
    nmap <buffer>         <leader>ls <plug>(lsp-document-symbol-search)
    nmap <buffer>         <leader>lS <plug>(lsp-workspace-symbol-search)
    nmap <buffer>         <leader>lf <plug>(lsp-document-format)
    xmap <buffer>         <leader>lf <plug>(lsp-document-range-format)
    nmap <buffer><silent> <leader>lF :LspDocumentFold<cr>
    nmap <buffer>         <leader>lK <plug>(lsp-hover)

    let g:vista_{&filetype}_executive = 'vim_lsp'
    " refer to doc to add more commands
    redraw | echomsg 'VIM LSP attached'
endfunction

function! s:on_lsp_float_opened() abort
  nnoremap <buffer><silent><nowait><expr> <M-j> lsp#scroll(+4)
  nnoremap <buffer><silent><nowait><expr> <M-k> lsp#scroll(-4)
  inoremap <buffer><silent><nowait><expr> <M-j> "\<c-r>=lsp#scroll(+4)\<cr>"
  inoremap <buffer><silent><nowait><expr> <M-k> "\<c-r>=lsp#scroll(-4)\<cr>"
  vnoremap <buffer><silent><nowait><expr> <M-j> lsp#scroll(+4)
  vnoremap <buffer><silent><nowait><expr> <M-k> lsp#scroll(-4)
endfunction

augroup vim-lsp-augroup
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
    autocmd User lsp_float_opened call s:on_lsp_float_opened()
augroup END

if has('patch-8.2.4780')
  let g:lsp_use_native_client = 1
endif
