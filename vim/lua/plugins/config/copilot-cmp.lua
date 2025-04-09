---@type LazyPluginSpec
return {
  "zbirenbaum/copilot-cmp",
  optional = true,
  lazy = true,
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("copilot_cmp").setup()
  end,
}
