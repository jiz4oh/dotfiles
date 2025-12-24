---@type LazyPluginSpec
return {
  "andrewferrier/debugprint.nvim",
  optional = true,
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
      "<C-G>p",
      mode = "i",
    },
    {
      "<C-G>v",
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
    -- … Other options
  },
}
