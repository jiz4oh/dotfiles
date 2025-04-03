---@type LazyPluginSpec
return {
  "stevearc/overseer.nvim",
  keys = {
    { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Open the task list" },
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Select and start a task" },
  },
  cmd = {
    "OverseerToggle",
    "OverseerRun",
    "OverseerRestartLast",
  },
  init = function()
    vim.api.nvim_create_user_command("OverseerRestartLast", function()
      local overseer = require("overseer")
      local tasks = overseer.list_tasks({ recent_first = true })
      if vim.tbl_isempty(tasks) then
        vim.notify("No tasks found", vim.log.levels.WARN)
      else
        overseer.run_action(tasks[1], "restart")
      end
    end, {})
  end,
  ---@type overseer.Config
  opts = {},
  config = function(_, opts)
    require("overseer").setup(opts)
    -- reference: https://github.com/search?q=path%3Alua%2Foverseer%2Ftemplate+language%3ALua+builder&type=code
    -- $_DOTFILES_PATH/vim/lua/overseer/template/user.lua
    require("overseer").load_template("user")
  end,
}
