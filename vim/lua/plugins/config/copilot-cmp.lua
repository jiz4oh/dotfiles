return {
  "zbirenbaum/copilot-cmp",
  lazy = true,
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "zbirenbaum/copilot.lua",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("copilot_cmp").setup()
  end,
}
