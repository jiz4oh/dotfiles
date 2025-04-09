---@type LazyPluginSpec
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  optional = true,
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
}
