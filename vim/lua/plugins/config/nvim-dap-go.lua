-- https://github.com/leoluz/nvim-dap-go/issues/95
-- sudo /usr/sbin/DevToolsSecurity -enable

---@type LazyPluginSpec
return {
  "leoluz/nvim-dap-go",
  optional = true,
  opts = {},
  ft = { "go" },
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-treesitter/nvim-treesitter",
  },
}
