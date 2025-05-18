---@type LazyPluginSpec
return {
  "miroshQa/debugmaster.nvim",
  optional = true,
  keys = {
    {
      "<leader>dd",
      function()
        require("debugmaster").mode.toggle()
      end,
      nowait = true,
      desc = "Toggle DebugMaster",
    },
    {
      "<C-/>",
      "<C-\\><C-n>",
      mode = "t",
      desc = "Exit terminal mode",
    },
  },
  opts = {},
  config = function()
    local dm = require("debugmaster")
    dm.plugins.osv_integration.enabled = true
  end,
  dependencies = {
    {
      "mfussenegger/nvim-dap",
    },
  },
}
