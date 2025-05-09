---@type LazyPluginSpec
return {
  "SirZenith/oil-vcs-status",
  optional = true,
  ft = {
    "oil"
  },
  dependencies = {
    "stevearc/oil.nvim",
    opts = {
      win_options = {
        signcolumn = "yes:2",
      },
    },
  },
  config = true,
}
