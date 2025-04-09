---@type LazyPluginSpec
return {
  "quangnguyen30192/cmp-nvim-tags",
  optional = true,
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = { "hrsh7th/nvim-cmp" },
}
