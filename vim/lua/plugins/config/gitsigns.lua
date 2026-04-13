---@module "lazy"
---@type LazyPluginSpec
return {
  "lewis6991/gitsigns.nvim",
  optional = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  enabled = vim.fn.has("nvim-0.9") == 1,
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "+" },
    },
    watch_gitdir = {
      follow_files = true,
    },
    attach_to_untracked = true,
    update_debounce = 100,
    signs_staged_enable = true,
  },
  keys = {
    {
      "]c",
      function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
          return
        end
        require("gitsigns").nav_hunk("next")
      end,
      desc = "Next Hunk",
    },
    {
      "[c",
      function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
          return
        end
        require("gitsigns").nav_hunk("prev")
      end,
      desc = "Previous Hunk",
    },
    {
      "<leader>hp",
      function()
        require("gitsigns").preview_hunk()
      end,
      desc = "Preview Hunk",
    },
    {
      "<leader>hs",
      function()
        require("gitsigns").stage_hunk()
      end,
      desc = "Stage Hunk",
    },
    {
      "<leader>hu",
      function()
        require("gitsigns").reset_hunk()
      end,
      desc = "Undo Hunk",
    },
    {
      "<leader>hs",
      function()
        require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end,
      mode = "x",
      desc = "Stage Hunk",
    },
    {
      "<leader>hu",
      function()
        require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end,
      mode = "x",
      desc = "Undo Hunk",
    },
  },
  specs = {
    {
      "airblade/vim-gitgutter",
      enabled = false,
    },
  },
}
