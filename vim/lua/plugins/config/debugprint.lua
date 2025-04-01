---@type LazyPluginSpec
return {
  "andrewferrier/debugprint.nvim",
  keys = {
    "g?p",
    "g?P",
    {
      "g?v",
      mode = { "n", "v" },
    },
    {
      "g?V",
      mode = { "n", "v" },
    },
    {
      "ctrl-g",
      "p",
      mode = "i",
    },
    {
      "ctrl-g",
      "v",
      mode = "i",
    },
    {
      "g?o",
      mode = { "o" },
    },
    {
      "g?O",
      mode = { "o" },
    },
  },
  cmd = {
    "ToggleCommentDebugPrints",
    "DeleteDebugPrints",
    "ResetDebugPrintsCounter",
  },
  opts = {
    keymaps = {
      normal = {
        plain_below = "g?p",
        plain_above = "g?P",
        variable_below = "g?v",
        variable_above = "g?V",
        variable_below_alwaysprompt = "",
        variable_above_alwaysprompt = "",
        textobj_below = "g?o",
        textobj_above = "g?O",
        toggle_comment_debug_prints = "",
        delete_debug_prints = "",
      },
      insert = {
        plain = "<C-G>p",
        variable = "<C-G>v",
      },
      visual = {
        variable_below = "g?v",
        variable_above = "g?V",
      },
    },
    commands = {
      toggle_comment_debug_prints = "ToggleCommentDebugPrints",
      delete_debug_prints = "DeleteDebugPrints",
      reset_debug_prints_counter = "ResetDebugPrintsCounter",
    },
    -- … Other options
  },
}
