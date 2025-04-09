---@type LazyPluginSpec
return {
  "saghen/blink.cmp",
  optional = true,
  event = { "InsertEnter", "CmdlineEnter" },
  -- use a release tag to download pre-built binaries
  version = "1.*",
  init = function()
    -- https://cmp.saghen.dev/recipes#hide-copilot-on-suggestion
    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuOpen",
      callback = function()
        local ok, copilot = pcall(require, "copilot.suggestion")
        if ok then
          copilot.dismiss()
        end
        vim.b.copilot_suggestion_hidden = true
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuClose",
      callback = function()
        vim.b.copilot_suggestion_hidden = false
      end,
    })
  end,
  -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = "default" },

    completion = {
      -- https://cmp.saghen.dev/recipes#border
      menu = {
        border = "single",
      },
      documentation = {
        window = { border = "single" },
        auto_show = true,
      },
    },

    cmdline = {
      -- https://cmp.saghen.dev/modes/cmdline.html#show-menu-automatically
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
        menu = {
          auto_show = function(ctx)
            return vim.fn.getcmdtype() == ":"
            -- enable for inputs as well, with:
            -- or vim.fn.getcmdtype() == '@'
          end,
        },
      },
    },

    term = {
      enabled = false,
      keymap = {
        preset = "inherit",
      },
      sources = {},
      completion = {
        trigger = {
          show_on_blocked_trigger_characters = {},
          show_on_x_blocked_trigger_characters = nil, -- Inherits from top level `completion.trigger.show_on_blocked_trigger_characters` config when not set
        },
        -- Inherits from top level config options when not set
        list = {
          selection = {
            -- When `true`, will automatically select the first item in the completion list
            preselect = nil,
            -- When `true`, inserts the completion item automatically when selecting it
            auto_insert = nil,
          },
        },
        -- Whether to automatically show the window when new completion items are available
        menu = { auto_show = nil },
        -- Displays a preview of the selected item on the current line
        ghost_text = { enabled = nil },
      },
    },

    -- default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, via `opts_extend`
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
      },
      providers = {
        -- https://cmp.saghen.dev/recipes.html#path-completion-from-cwd-instead-of-current-buffer-s-directory
        path = {
          opts = {
            get_cwd = function(_)
              return vim.fn.getcwd()
            end,
          },
        },
      },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" },

    -- experimental signature help support
    signature = { enabled = true },
  },
  -- allows extending the providers array elsewhere in your config
  -- without having to redefine it
  opts_extend = { "sources.default" },
  specs = {
    {
      "williamboman/mason-lspconfig.nvim",
      opts = function(_, opts)
        if vim.fn.has("nvim-0.11") ~= 1 then
          opts["capabilities"] = require("blink.cmp").get_lsp_capabilities({}, true)
        end
      end,
    },
  },
}
