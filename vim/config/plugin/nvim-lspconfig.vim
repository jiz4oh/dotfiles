function! s:on_lsp_buffer_enabled() abort
  let b:ale_disable_lsp = 1
  if index(['vim-plug'], &filetype) > -1
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
  if has('nvim-0.8')
    nnoremap <buffer> <leader>lf <cmd>lua vim.lsp.buf.format()<CR>
    xnoremap <buffer> <leader>lf <cmd>lua vim.lsp.buf.format()<CR>
  else
    nnoremap <buffer> <leader>lf <cmd>lua vim.lsp.buf.formatting()<CR>
    xnoremap <buffer> <leader>lf <cmd>lua vim.lsp.buf.range_formatting()<CR>
  endif
  nnoremap <buffer> <leader>lK <cmd>lua vim.lsp.buf.hover()<CR>
  nnoremap <buffer> <leader>la <cmd>lua vim.lsp.buf.code_action()<CR>
  if has('nvim-0.8')
    xnoremap <buffer> <leader>la <cmd>lua vim.lsp.buf.code_action()<CR>
  else
    xnoremap <buffer> <leader>la <cmd>lua vim.lsp.buf.range_code_action()<CR>
  endif

  try
    let g:vista_{&filetype}_executive = 'nvim_lsp'
  catch
  endtry
  let msg = 'NVIM LSP attached'
  if !has('nvim')
    redraw
    echomsg msg
  end
endfunction

augroup nvim-lspconfig-augroup
  autocmd!

  if has('nvim-0.8')
    autocmd LspAttach * call s:on_lsp_buffer_enabled()
lua<<EOF
-- do not set tagfunc, it's slowly with cmp-nvim-tags
TAGFUNC_ALWAYS_EMPTY = function()
    return vim.NIL
end

-- if tagfunc is already registered, nvim lsp will not try to set tagfunc as vim.lsp.tagfunc.
vim.o.tagfunc = "v:lua.TAGFUNC_ALWAYS_EMPTY"

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
  end,
})
EOF
  else
    autocmd User LspAttach call s:on_lsp_buffer_enabled()
  end
augroup END
