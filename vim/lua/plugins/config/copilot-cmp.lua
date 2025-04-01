---@type LazyPluginSpec
return {
  "zbirenbaum/copilot-cmp",
  lazy = true,
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    import = "plugins.config.copilot",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("copilot_cmp").setup()
  end,
}
