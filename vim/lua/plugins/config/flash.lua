---@type LazyPluginSpec
return {
  "folke/flash.nvim",
  optional = true,
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    modes = {
      search = {
        -- 默认在执行 / 或 ? 搜索时开启 Flash
        enabled = true,
        trigger = "/",
      },
      char = {
        enabled = false, -- 保持原生的 f/t 逻辑，只在当前行生效，不显示 flash 标签
      },
    },
  },
  keys = {
    {
      "f",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash Jump",
    },
    {
      "F",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },
    {
      "<c-s>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search",
    },
  },
  spec = {
    {
      "easymotion/vim-easymotion",
      enabled = false,
    },
    {
      "echasnovski/mini.jump2d",
      enabled = false,
    },
  },
}
