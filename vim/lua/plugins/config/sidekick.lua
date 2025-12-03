local mux = {
  enabled = vim.fn.executable("tmux") == 1,
  backend = "tmux",
}

---@type LazyPluginSpec
return {
  "folke/sidekick.nvim",
  optional = true,
  ---@class sidekick.Config
  opts = {
    cli = {
      mux = mux,
      win = {
        layout = "float",
      },
    },
  },
  keys = {
    {
      "<tab>",
      function()
        -- if there is a next edit, jump to it, otherwise apply it if any
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>" -- fallback to normal tab
        end
      end,
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },
    {
      "<c-,>",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Sidekick Toggle",
      mode = { "n", "t", "i", "x" },
    },
    {
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n", "x" },
      desc = "Sidekick Select Prompt",
    },
    {
      "<leader>ac",
      function()
        require("sidekick.nes").clear()
      end,
      mode = { "n", "x" },
      desc = "Clear the current Next Edit Suggestion.",
    },
  },
  specs = {
    {
      "saghen/blink.cmp",
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        keymap = {
          ["<Tab>"] = {
            "snippet_forward",
            function() -- sidekick next edit suggestion
              return require("sidekick").nes_jump_or_apply()
            end,
            function() -- if you are using Neovim's native inline completions
              if vim.lsp.inline_completion then
                return vim.lsp.inline_completion.get()
              end
            end,
            "fallback",
          },
        },
      },
    },
  },
}
