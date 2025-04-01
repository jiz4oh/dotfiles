---@type LazyPluginSpec
return {
  "hrsh7th/cmp-nvim-lsp",
  event = "InsertEnter",
  -- dependencies = {
  --   "hrsh7th/nvim-cmp",
  -- },
  config = function()
    pcall(
      vim.lsp.config,
      "*",
      vim.tbl_deep_extend("force", vim.lsp.config["*"], {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
    )

    require("cmp_nvim_lsp").setup()
  end,
}
