return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  event = { "VeryLazy" },
  opts = {
    -- vim.opt.foldmethod = 'expr'
    -- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    auto_install = true,

    ensure_installed = {
      "html",
      "css",
      "tsx",
      "javascript",
      "json",
      "toml",
      "yaml",
      "ruby",
      "go",
    },
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
  },
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
}
