---@module "lazy"
---@type LazyPluginSpec
return {
  "linrongbin16/gitlinker.nvim",
  optional = true,
  cmd = "GitLink",
  keys = {
    { "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Yank git link" },
    { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
  },

  init = function()
    vim.api.nvim_create_user_command("GBrowse", function()
      require("gitlinker").link({ action = require("gitlinker.actions").system })
    end, {
      range = true,
    })
  end,
  opts = {
    router = {
      browse = {
        ["^ssh%.github%.com"] = "https://github.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/blob/"
          .. "{_A.REV}/"
          .. "{_A.FILE}?plain=1" -- '?plain=1'
          .. "#L{_A.LSTART}"
          .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
      },
      blame = {
        ["^ssh%.github%.com"] = "https://github.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/blame/"
          .. "{_A.REV}/"
          .. "{_A.FILE}?plain=1" -- '?plain=1'
          .. "#L{_A.LSTART}"
          .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
      },
    },
  },
}
