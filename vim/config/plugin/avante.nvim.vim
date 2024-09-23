map <leader>aa :AvanteAsk<CR>

lua<<EOF
vim.api.nvim_create_autocmd('User', {
  pattern = {"avante.nvim"},
  callback = function(event)
    require('avante_lib').load()

    require('avante').setup({
      provider = "copilot",
      auto_suggestions_provider = "copilot",
      claude = {
        endpoint = os.getenv("ANTHROPIC_ENDPOINT") or "https://api.anthropic.com",
      },
    })
  end
})
EOF