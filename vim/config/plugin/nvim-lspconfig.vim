function! s:on_lsp_buffer_enabled() abort
  if index(['vim-plug'], &filetype)
    return
  end
  setlocal omnifunc=v:lua.vim.lsp.omnifunc

  nnoremap <buffer> <leader>ld <cmd>lua vim.lsp.buf.definition()<CR>
  nnoremap <buffer> <leader>lD <cmd>lua vim.lsp.buf.declaration()<CR>
  nnoremap <buffer> <leader>lt <cmd>lua vim.lsp.buf.type_definition()<CR>
  nnoremap <buffer> <leader>li <cmd>lua vim.lsp.buf.implementation()<CR>
  nnoremap <buffer> <leader>lr <cmd>lua vim.lsp.buf.references()<CR>
  nnoremap <buffer> <leader>lR <cmd>lua vim.lsp.buf.rename()<CR>
  nnoremap <buffer> <leader>ls <cmd>lua vim.lsp.buf.document_symbol()<CR>
  nnoremap <buffer> <leader>lS <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
  nnoremap <buffer> <leader>lf <cmd>lua vim.lsp.buf.formatting()<CR>
  xnoremap <buffer> <leader>lf <cmd>lua vim.lsp.buf.range_formatting()<CR>
  nnoremap <buffer> <leader>lK <cmd>lua vim.lsp.buf.hover()<CR>

  let g:vista_{&filetype}_executive = 'nvim_lsp'
  redraw | echomsg 'NVIM LSP attached'
endfunction

augroup nvim-lspconfig-augroup
  autocmd!

  if has('nvim-0.8')
    autocmd LspAttach * call s:on_lsp_buffer_enabled()
  else
    autocmd User LspAttach call s:on_lsp_buffer_enabled()
  end
augroup END
