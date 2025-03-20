return {
  {
    import = "plugins.config.nvim-treesitter",
  },
  {
    import = "plugins.config.firenvim",
  },
  {
    "folke/which-key.nvim",
    enabled = vim.fn.has("nvim-0.10") == 1,
    import = "plugins.config.which-key",
  },
  {
    "williamboman/mason.nvim",
    import = "plugins.config.mason",
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    import = "plugins.config.mason-tool-installer",
  },
  {
    "folke/snacks.nvim",
    enabled = vim.fn.has("nvim-0.9.4") == 1,
    import = "plugins.config.snacks",
  },
  {
    "mhinz/vim-hugefile",
    enabled = vim.fn.has("nvim-0.9.4") == 0,
  },
}
