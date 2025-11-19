---@type LazyPluginSpec
return {
  "stevearc/overseer.nvim",
  optional = true,
  enabled = vim.fn.has("nvim-0.11") == 1,
  keys = {
    { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Open the task list" },
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Select and start a task" },
    { "<leader>ol", "<cmd>OverseerRestartLast<cr>", desc = "Restart last task" },
    { "<leader>of", "<cmd>OverseerFloatLast<cr>", desc = "Open last task in float window" },
    { "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Select a task to run an action on" },
    { "<leader>ox", "<cmd>OverseerShell<cr>", desc = "Run command on shell" },
  },
  cmd = {
    "OverseerOpen",
    "OverseerClose",
    "OverseerToggle",
    "OverseerShell",
    "OverseerRun",
    "OverseerTaskAction",
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
    default_template_prompt = "missing", -- https://github.com/stevearc/overseer.nvim/issues/18
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
  specs = {
    {
      "folke/which-key.nvim",
      optional = true,
      opts = {
        spec = {
          { "<leader>o", group = "overseer" },
        },
      },
    },
  },
}
