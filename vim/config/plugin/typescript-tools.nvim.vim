lua<<EOF
-- https://github.com/hinell/lsp-timeout.nvim/issues/12#issuecomment-1779816239
local filetypes = {
  "javascript",
  "js",
  "jsx",
  "ts",
  "tsx",
  "typescript",
  "javascriptreact",
  "javascript.jsx",
  "typescript",
  "typescriptreact",
  "typescript.tsx",
}
vim.api.nvim_create_autocmd('Filetype', {
  pattern = filetypes,
  callback = function(event)
    require("typescript-tools").setup({
      filetypes = filetypes
    })
  end
})
EOF
