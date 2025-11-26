---@type LazyPluginSpec
return {
  "esmuellert/vscode-diff.nvim",
  optional = true,
  keys = {
    {
      "<leader>df",
      "<cmd>CodeDiff<cr>",
      desc = "activate vscode diff",
    },
  },
  opts = {},
}
