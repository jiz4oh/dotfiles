---@type LazyPluginSpec
return {
  "RRethy/nvim-treesitter-endwise",
  optional = true,
  event = "InsertEnter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
}
