return {
  {
    "RRethy/nvim-treesitter-endwise",
    enabled = vim.g.with_treesitter == 1,
    import = "plugins.config.nvim-treesitter-endwise",
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = vim.g.with_treesitter == 1,
    import = "plugins.config.nvim-treesitter-textobjects",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = vim.g.with_treesitter == 1,
  },
  import = "plugins.config.nvim-treesitter",
}
