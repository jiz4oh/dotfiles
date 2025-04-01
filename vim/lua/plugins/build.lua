---@type LazySpec[]
return {
  {
    "stevearc/overseer.nvim",
    enabled = vim.fn.has("nvim-0.8") == 1,
    import = "plugins.config.overseer",
  },
  {
    "pianocomposer321/officer.nvim",
    enabled = vim.fn.has("nvim-0.8") == 1,
    import = "plugins.config.officer",
  },
}
