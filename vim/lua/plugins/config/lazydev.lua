return {
  "folke/lazydev.nvim",
  enabled = vim.fn.has('nvim-0.10') == 1,
  ft = "lua", -- only load on lua files
  opts = {
    library = {
      { path = "~/.hammerspoon/Spoons/EmmyLua.spoon/annotations" },
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
