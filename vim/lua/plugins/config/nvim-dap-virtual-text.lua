---@type LazyPluginSpec
return {
  "theHamsta/nvim-dap-virtual-text",
  optional = true,
  lazy = true,
  config = function()
    require("nvim-dap-virtual-text").setup()
  end,
}
