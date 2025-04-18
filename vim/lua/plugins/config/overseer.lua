---@type LazyPluginSpec
return {
  "stevearc/overseer.nvim",
  optional = true,
  keys = {
    { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Open the task list" },
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Select and start a task" },
    { "<leader>ol", "<cmd>OverseerRestartLast<cr>", desc = "Restart last task" },
    { "<leader>of", "<cmd>OverseerFloatLast<cr>", desc = "Open last task in float window" },
    { "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Select a task to run an action on" },
    { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Run an action on the most recent task, or the task under the cursor" },
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

    vim.api.nvim_create_user_command("OverseerFloatLast", function()
      local overseer = require("overseer")
      local tasks = overseer.list_tasks({ recent_first = true })
      if vim.tbl_isempty(tasks) then
        vim.notify("No tasks found", vim.log.levels.WARN)
      else
        overseer.run_action(tasks[1], "open float")
        vim.cmd("noautocmd stopinsert")
      end
    end, {})
  end,
  ---@type overseer.Config
  opts = {
    strategy = "jobstart",
    task_list = {
      max_height = { 40, 0.7 },
    },
    component_aliases = {
      start = {
        {
          "open_output",
          on_start = "always",
          on_complete = "failure",
          direction = "float",
          focus = true,
        },
        "on_exit_set_status",
      },
      dispatch = {
        "default",
      },
    },
  },
  config = function(_, opts)
    require("overseer").setup(opts)
    -- reference: https://github.com/search?q=path%3Alua%2Foverseer%2Ftemplate+language%3ALua+builder&type=code
    -- $_DOTFILES_PATH/vim/lua/overseer/template/user.lua
    require("overseer").load_template("user")
  end,
}
