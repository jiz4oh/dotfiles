return {
  "miversen33/netman.nvim",
  event = "VeryLazy",
  cmd = {
    "NmloadProvider",
    "Nmlogs",
    "Nmdelete",
    "Nmread",
    "Nmwrite",
  },
  init = function()
    vim.g.disable_netrw = 1
  end,
  lazy = not (vim.fn.argc() > 0),
  opts = {},
}
