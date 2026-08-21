---@type LazySpec[]
return {
  {
    "barrettruth/diffs.nvim",
    -- diffs.nvim uses the positional vim.validate API introduced in 0.11.
    enabled = vim.fn.has("nvim-0.11") == 1,
  },
  {
    "andymass/vim-matchup",
  },
  {
    "hat0uma/csvview.nvim",
  },
  -- 已经没维护了，大 csv 打开无法翻页
  -- {
  --   "VidocqH/data-viewer.nvim",
  --   enabled = vim.fn.has("nvim-0.8") == 1,
  --   import = "plugins.config.data-viewer",
  -- },
  {
    "adriaanzon/vim-textobj-matchit",
    import = "plugins.config.vim-textobj-matchit",
  },
  {
    "milanglacier/yarepl.nvim",
  },
  -- conflict with LivePreview
  -- {
  --   "chrisgrieser/nvim-early-retirement",
  -- },
}
