---@type LazySpec[]
return {
  {
    "andrewferrier/debugprint.nvim",
    enabled = vim.g.as_ide == 1,
    import = "plugins.config.debugprint",
  },
  {
    "mfussenegger/nvim-dap",
    enabled = vim.g.as_ide == 1,
  },
  {
    "miroshQa/debugmaster.nvim",
    enabled = vim.g.as_ide == 1,
  },
  --- {{{ dap configurations
  {
    "mfussenegger/nvim-dap-python",
    enabled = vim.g.as_ide == 1,
  },
  {
    "jbyuki/one-small-step-for-vimkind",
    enabled = vim.g.as_ide == 1,
  },
  {
    "leoluz/nvim-dap-go",
    enabled = vim.g.as_ide == 1,
  },
  --- }}}
}
