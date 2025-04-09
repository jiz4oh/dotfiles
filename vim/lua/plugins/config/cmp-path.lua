---@type LazyPluginSpec
return {
  "hrsh7th/cmp-path",
  optional = true,
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = { "hrsh7th/nvim-cmp" },
}
