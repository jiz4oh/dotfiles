---@type LazyPluginSpec
return {
  "theHamsta/nvim-dap-virtual-text",
  optional = true,
  config = function()
    require("nvim-dap-virtual-text").setup()
  end,
}
