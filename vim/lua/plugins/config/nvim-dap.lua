---@type LazyPluginSpec
return {
  "mfussenegger/nvim-dap",
  optional = true,
  lazy = true,
  opts = {},
  -- stylua: ignore
  config = function(_, opts)
    local dap = require("dap")
    for k,v in pairs(opts) do
      if type(v) == type({}) then
        dap[k] = vim.tbl_deep_extend("force", dap[k] or {}, v)
      else
        dap[k] = v
      end
    end
  end,
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
  },
}
