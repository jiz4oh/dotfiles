---@type LazyPluginSpec
return {
  "zbirenbaum/copilot.lua",
  optional = true,
  enabled = vim.fn.executable("node") and vim.fn.has("nvim-0.10") == 1,
  event = "InsertEnter",
  cmd = "Copilot",
  opts = {
    -- suggestion = { enabled = false },
    -- panel = { enabled = false },
    copilot_node_command = vim.g.node_path,
  },
  specs = {
    {
      "hrsh7th/nvim-cmp",
      dependencies = { -- this will only be evaluated if nvim-cmp is enabled
        "zbirenbaum/copilot-cmp",
      },
    },

    -- blink.cmp integration
    {
      "saghen/blink.cmp",
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
      opts = {
        auto_suggestions_provider = "copilot",
        copilot = {
          model = vim.g.copilot_model or "gpt-40-2024-08-06",
        },
      },
    },
  },
}
