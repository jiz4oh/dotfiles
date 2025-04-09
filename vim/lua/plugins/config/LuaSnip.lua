---@type LazySpec
return {
  "L3MON4D3/LuaSnip",
  lazy = true,
  -- follow latest release.
  version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  -- install jsregexp (optional!).
  build = "make install_jsregexp",
  dependencies = {
    "honza/vim-snippets",
    "rafamadriz/friendly-snippets",
  },
  specs = {
    -- nvim-cmp integration
    {
      "hrsh7th/nvim-cmp",
      optional = true,
      opts = function(_, opts)
        opts.snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        }
        if type(opts.sources) == "table" then
          table.insert(opts.sources, { name = "luasnip" })
        end
      end,
      dependencies = {
        "saadparwaiz1/cmp_luasnip",
      },
    },

    -- blink.cmp integration
    {
      "saghen/blink.cmp",
      optional = true,
      opts = {
        snippets = {
          preset = "luasnip",
        },
      },
    },
  },
}
