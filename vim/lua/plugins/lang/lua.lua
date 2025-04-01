---@type LazySpec[]
return {
  {
    "folke/lazydev.nvim",
    import = "plugins.config.lazydev",
  },
  {
    "sam4llis/nvim-lua-gf",
    lazy = false,
    ft = { "lua", "vim" },
    enabled = vim.fn.has("nvim-0.11") ~= 1,
  },
}
