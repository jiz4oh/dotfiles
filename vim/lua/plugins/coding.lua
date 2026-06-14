local enabled = vim.g.as_ide == 1

vim.g.complete_engine = vim.g.complete_engine or vim.fn.has("nvim-0.11") == 1 and "blink" or "cmp"

---@type LazySpec[]
return {
  {
    "hrsh7th/nvim-cmp",
    enabled = vim.g.complete_engine == "cmp",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "hrsh7th/cmp-buffer",
      "cmp-cmdline",
      "quangnguyen30192/cmp-nvim-tags",
      "hrsh7th/cmp-path",
      "garyhurtz/cmp_kitty",
    },
  },
  {
    "saghen/blink.cmp",
    enabled = vim.g.complete_engine == "blink",
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
  },
  {
    "fang2hou/blink-copilot",
  },
  {
    "esmuellert/vscode-diff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
  },
}
