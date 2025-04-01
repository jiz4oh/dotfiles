local lsp_enabled = vim.lsp ~= nil and vim.g.as_ide == 1

---@type LazySpec[]
return {
  {
    "mrded/nvim-lsp-notify",
    enabled = lsp_enabled,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    enabled = lsp_enabled and vim.g.complete_engine == "cmp",
    import = "plugins.config.cmp-nvim-lsp",
  },
  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    enabled = lsp_enabled and vim.g.complete_engine == "cmp",
    import = "plugins.config.cmp-nvim-lsp-signature-help",
  },
  {
    "ojroques/nvim-lspfuzzy",
    enabled = lsp_enabled,
    import = "plugins.config.nvim-lspfuzzy",
  },
  {
    "pmizio/typescript-tools.nvim",
    enabled = lsp_enabled,
    import = "plugins.config.typescript-tools",
  },
  {
    "zeioth/garbage-day.nvim",
    event = "LspAttach",
    enabled = lsp_enabled and vim.fn.has("nvim-0.10"),
    import = "plugins.config.garbage-day",
  },
  {
    "williamboman/mason-lspconfig.nvim",
    enabled = lsp_enabled,
    import = "plugins.config.mason-lspconfig",
  },
  {
    "neovim/nvim-lspconfig",
    enabled = lsp_enabled,
    import = "plugins.config.nvim-lspconfig",
  },
}
