local enabled = vim.g.as_ide == 1

vim.g.complete_engine = vim.g.complete_engine or vim.fn.has("nvim-0.11") == 1 and 'blink' or 'cmp'

---@type LazySpec[]
return {
  {
    "L3MON4D3/LuaSnip",
    enabled = enabled,
    import = "plugins.config.LuaSnip",
  },
  {
    enabled = enabled and vim.g.complete_engine == 'cmp',
    import = "plugins.extras.coding.nvim-cmp",
  },
  {
    enabled = enabled and vim.g.complete_engine == 'blink',
    import = "plugins.config.blink",
  },
}
