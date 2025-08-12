---@type LazyPluginSpec
return {
  "williamboman/mason.nvim",
  optional = true,
  event = { "FileType" },
  enabled = vim.fn.has("nvim-0.10") == 1,
  cmd = { "Mason", "MasonUpdate" },
  build = ":MasonUpdate",
  config = function()
    require("mason").setup()
  end,
}
