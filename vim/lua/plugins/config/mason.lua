---@type LazyPluginSpec
return {
  "williamboman/mason.nvim",
  optional = true,
  cmd = { "Mason", "MasonUpdate" },
  build = ":MasonUpdate",
  config = function()
    require("mason").setup()
  end,
}
