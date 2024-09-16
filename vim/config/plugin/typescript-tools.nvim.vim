lua<<EOF
vim.api.nvim_create_autocmd('Filetype', {
  pattern = {'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx'},
  callback = function(event)
    require("typescript-tools").setup {}
  end
})
EOF
