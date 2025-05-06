---@type LazyPluginSpec
return {
  "mfussenegger/nvim-dap",
  optional = true,
  lazy = true,
  opts = {},
  -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
  config = function()
    local dap = require("dap")
  end,
  lazy = true,
}
