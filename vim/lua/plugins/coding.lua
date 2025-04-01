local enabled = vim.g.as_ide == 1

local blink = vim.fn.has("nvim-0.11") == 1

---@type LazySpec[]
return {
  {
    "L3MON4D3/LuaSnip",
    enabled = enabled,
    import = "plugins.config.LuaSnip",
  },
  {
    enabled = enabled and not blink,
    import = "plugins.extras.coding.nvim-cmp",
  },
  {
    enabled = enabled and blink,
    import = "plugins.config.blink",
  },
}
