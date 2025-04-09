---@type LazySpec[]
return {
  {
    "preservim/nerdtree",
    import = "plugins.config.nerdtree",
  },
  {
    "miversen33/netman.nvim",
    import = "plugins.config.netman",
  },
  {
    "hedyhli/outline.nvim",
    cond = vim.g.as_ide == 1,
    import = "plugins.config.outline",
  },
}
