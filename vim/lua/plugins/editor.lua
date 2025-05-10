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
    "milanglacier/yarepl.nvim",
  },
  {
    "chrisgrieser/nvim-early-retirement",
  },
}
