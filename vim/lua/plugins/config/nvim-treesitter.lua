local opts = {
  -- vim.opt.foldmethod = 'expr'
  -- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
  indent = {
    enable = true,
  },
  highlight = {
    enable = true,
    disable = { "git", "gitcommit", "json" },
    additional_vim_regex_highlighting = { "embedded_template", "ruby" },
  },
  endwise = {
    enable = true,
  },
}

if vim.g.with_treesitter == 1 then
  opts = vim.tbl_deep_extend("force", opts, {
    auto_install = true,
  })
end

---@type LazyPluginSpec
return {
  "nvim-treesitter/nvim-treesitter",
  optional = true,
  build = ":TSUpdate",
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  enabled = vim.fn.has("nvim-0.10") == 1,
  event = { "VeryLazy" },
  opts = opts,
  lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
  init = function(plugin)
    -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
    -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
    -- no longer trigger the **nvim-treesitter** module to be loaded in time.
    -- Luckily, the only things that those plugins need are the custom queries, which we make available
    -- during startup.
    require("lazy.core.loader").add_to_rtp(plugin)
    require("nvim-treesitter.query_predicates")
  end,
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
  specs = {
    {
      "hedyhli/outline.nvim",
      dependencies = {
        "epheien/outline-treesitter-provider.nvim",
      },
      opts = function(_, opts)
        if opts.providers == nil then
          return opts
        end

        if opts.providers.priority == nil then
          opts.providers.priority = { "lsp", "treesitter" }
          return opts
        end

        local i = #opts.providers.priority + 1
        for index, v in ipairs(opts.providers.priority) do
          if v == "ctags" then
            i = index
            break
          end
        end

        table.insert(opts.providers.priority, i, "treesitter")
      end,
    },
  },
}
