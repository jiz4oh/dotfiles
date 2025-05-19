---@type LazyPluginSpec
return {
  "zbirenbaum/copilot.lua",
  optional = true,
  enabled = vim.fn.executable("node") == 1 and vim.fn.has("nvim-0.10") == 1,
  event = "InsertEnter",
  cmd = "Copilot",
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
  opts = {
    -- suggestion = { enabled = false },
    -- panel = { enabled = false },
    copilot_node_command = vim.g.node_path,
  },
  specs = {
    {
      "hrsh7th/nvim-cmp",
      optional = true,
      dependencies = { -- this will only be evaluated if nvim-cmp is enabled
        "zbirenbaum/copilot-cmp",
      },
    },

    -- blink.cmp integration
    {
      "saghen/blink.cmp",
      optional = true,
      dependencies = {
        "fang2hou/blink-copilot",
      },
      opts = {
        sources = {
          default = { "copilot" },
          providers = {
            copilot = {
              name = "copilot",
              module = "blink-copilot",
              score_offset = 100,
              async = true,
            },
          },
        },
      },
    },
    {
      "yetone/avante.nvim",
      optional = true,
      opts = {
        auto_suggestions_provider = "copilot",
        copilot = {
          model = vim.g.copilot_model or "gpt-40-2024-08-06",
        },
      },
    },
  },
}
