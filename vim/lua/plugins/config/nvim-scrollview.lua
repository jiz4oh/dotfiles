---@type LazyPluginSpec
return {
  "dstein64/nvim-scrollview",
  optional = true,
  opts = {
    signs_on_startup = { "latestchange", "quickfix", "marks", "folds", "changelist" },
    floating_windows = true,
  },
}
