---@type LazyPluginSpec
return {
  "chrisgrieser/nvim-origami",
  optional = true,
  event = "VeryLazy",
  opts = {
    autoFold = {
      enabled = false, -- https://github.com/neovim/neovim/issues/34042
    },
  },
}
