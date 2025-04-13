local opts = {
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
  build = function()
    local ok, m = pcall(require, "nvim-treesitter.install")
    if ok then
      m.update({ with_sync = true })
    end
  end,
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
    pcall(require, "nvim-treesitter.query_predicates")
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local ok, parsers = pcall(require, "nvim-treesitter.parsers")
        if ok then
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
          if parsers.has_parser(filetype) then
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
            vim.wo.foldlevel = 3
            vim.cmd("normal! zvzz")
          end
        end
      end,
    })
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
