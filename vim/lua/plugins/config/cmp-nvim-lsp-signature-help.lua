---@type LazyPluginSpec
return {
  "hrsh7th/cmp-nvim-lsp-signature-help",
  optional = true,
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/nvim-cmp",
  },
}
