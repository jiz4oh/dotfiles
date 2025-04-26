---@type LazySpec[]
return {
  { "stevearc/oil.nvim" },
  {
    -- "refractalize/oil-git-status.nvim", -- it doesn't display unstaged git status
    "SirZenith/oil-vcs-status",
    dependencies = {
      "stevearc/oil.nvim",
      opts = {
        win_options = {
          signcolumn = "yes:2",
        },
      },
    },
    config = true,
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
}
