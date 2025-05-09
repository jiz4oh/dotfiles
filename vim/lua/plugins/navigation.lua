---@type LazySpec[]
return {
  { "stevearc/oil.nvim" },
  {
    -- "refractalize/oil-git-status.nvim", -- it doesn't display unstaged git status
    "SirZenith/oil-vcs-status",
  },
  {
    "preservim/nerdtree",
    import = "plugins.config.nerdtree",
  },
  {
    -- "miversen33/netman.nvim",
    -- import = "plugins.config.netman",
  },
  {
    "hedyhli/outline.nvim",
    cond = vim.g.as_ide == 1,
    import = "plugins.config.outline",
  },
  {
    "echasnovski/mini.jump2d",
  },
}
