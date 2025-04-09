---@type LazyPluginSpec
return {
  "jiz4oh/cmp-cmdline",
  name = "cmp-cmdline",
  optional = true,
  event = "CmdlineEnter",
  dependencies = { "hrsh7th/nvim-cmp" },
}
