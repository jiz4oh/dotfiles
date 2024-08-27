function! s:on_lsp_buffer_enabled() abort
  let b:ale_disable_lsp = 1
  if index(['vim-plug'], &filetype) > -1
    return
  end

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
    vim.keymap.set('n', '<leader>lr', function() vim.lsp.buf.references({includeDeclaration = false}) end)
    vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition)
    vim.keymap.set('n', '<leader>lD', vim.lsp.buf.declaration)
    vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition)
    vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation)
    vim.keymap.set('n', '<leader>lR', vim.lsp.buf.rename)
    vim.keymap.set('n', '<leader>ls', vim.lsp.buf.document_symbol)
    vim.keymap.set('n', '<leader>lS', vim.lsp.buf.workspace_symbol)
    vim.keymap.set('n', '<leader>lK', vim.lsp.buf.hover)
    vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action)

    if vim.fn.has('nvim-0.8') == 1 then
      vim.keymap.set('x', '<leader>la', vim.lsp.buf.code_action)
      vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
      vim.keymap.set('x', '<leader>lf', vim.lsp.buf.format)
    else
      vim.keymap.set('x', '<leader>la', vim.lsp.buf.range_code_action)
      vim.keymap.set('n', '<leader>lf', vim.lsp.buf.formatting)
      vim.keymap.set('x', '<leader>lf', vim.lsp.buf.range_formatting)
    end
  end,
})
EOF
  else
    autocmd User LspAttach call s:on_lsp_buffer_enabled()
  end
augroup END
