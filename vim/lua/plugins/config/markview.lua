---@type LazyPluginSpec
return {
  "OXY2DEV/markview.nvim",
  optional = true,
  -- lazy = false, -- Recommended
  ft = "markdown", -- If you decide to lazy-load anyway
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
}
