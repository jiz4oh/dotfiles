local lsp_enabled = vim.lsp ~= nil and vim.g.as_ide == 1

---@type LazySpec[]
return {
  { "b0o/schemastore.nvim", lazy = true },
  {
    "mrded/nvim-lsp-notify",
    enabled = lsp_enabled,
  },
  lsp_enabled and {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
    },
  } or {},
  {
    "kosayoda/nvim-lightbulb",
    enabled = lsp_enabled,
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
    enabled = lsp_enabled and vim.fn.has("nvim-0.10") == 1,
    import = "plugins.config.mason-lspconfig",
  },
  {
    "neovim/nvim-lspconfig",
    enabled = lsp_enabled and vim.fn.has("nvim-0.10") == 1,
    import = "plugins.config.nvim-lspconfig",
  },
  {
    "aznhe21/actions-preview.nvim",
    enabled = lsp_enabled,
  },
}
