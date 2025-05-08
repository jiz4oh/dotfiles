local markview = vim.fn.has("nvim-0.10.1") == 1

---@type LazySpec[]
return {
  {
    "echasnovski/mini.icons",
  },
  {
    import = "plugins.config.nvim-scrollview",
    enabled = vim.fn.has("nvim-0.6") == 1,
  },
  -- {
  -- 	"rcarriga/nvim-notify",
  -- 	enabled = vim.fn.has("nvim-0.5") == 1,
  -- 	import = "plugins.config.nvim-notify"
  -- },
  {
    import = "plugins.config.markview",
    enabled = markview,
  },
  {
    "iamcco/markdown-preview.nvim",
  },
  {
    import = "plugins.config.vim-dadbod-ui",
  },
  {
    "chrisgrieser/nvim-origami"
  }
}
