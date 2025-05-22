---@type LazyPluginSpec
return {
  "williamboman/mason.nvim",
  optional = true,
  version = "v1.*",
  event = { "FileType" },
  enabled = vim.fn.has("nvim-0.7") == 1,
  cmd = { "Mason", "MasonUpdate" },
  build = ":MasonUpdate",
  config = function()
    require("mason").setup()
  end,
}
