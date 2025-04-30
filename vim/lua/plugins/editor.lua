---@type LazySpec[]
return {
  {
    "VidocqH/data-viewer.nvim",
    enabled = vim.fn.has("nvim-0.8") == 1,
    import = "plugins.config.data-viewer",
  },
  {
    "adriaanzon/vim-textobj-matchit",
    import = "plugins.config.vim-textobj-matchit",
  },
  {
    "andrewferrier/debugprint.nvim",
    enabled = vim.g.as_ide == 1,
    import = "plugins.config.debugprint",
  },
  {
    "milanglacier/yarepl.nvim",
  },
}
