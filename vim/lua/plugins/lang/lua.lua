---@type LazySpec[]
return {
  {
    "folke/lazydev.nvim",
    import = "plugins.config.lazydev",
  },
  { -- optional cmp completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },
  {
    "sam4llis/nvim-lua-gf",
    lazy = false,
    ft = { "lua", "vim" },
    enabled = vim.fn.has("nvim-0.11") ~= 1,
  },
}
