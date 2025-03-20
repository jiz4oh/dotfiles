return {
  {
    "stevearc/overseer.nvim",
    enabled = vim.fn.has("nvim-0.8") == 1,
    import = "plugins.config.overseer",
  },
  {
    "pianocomposer321/officer.nvim",
    dependencies = {
      "stevearc/overseer.nvim",
    },
    import = "plugins.config.officer",
  },
}
