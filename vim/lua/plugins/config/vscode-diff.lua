---@type LazyPluginSpec
return {
  "esmuellert/vscode-diff.nvim",
  optional = true,
  cmd = "CodeDiff",
  keys = {
    {
      "<leader>df",
      "<cmd>CodeDiff<cr>",
      desc = "activate vscode diff",
    },
  },
  opts = {
    diff = {
      conflict_result_position = "center",
      conflict_result_width_ratio = { 1, 1, 1 }, -- 中间 result 更宽
    },
    explorer = {
      position = "bottom",
      view_mode = "list",
      flatten_dirs = true,
      initial_focus = "explorer",
    },
  },
}
