---@type LazyPluginSpec
return {
  "zeioth/garbage-day.nvim",
  optional = true,
  event = "LspAttach",
  dependencies = "neovim/nvim-lspconfig",
}
