return {
  "stevearc/overseer.nvim",
  keys = {
    { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Open the task list" },
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Select and start a task" },
  },
  cmd = {
    "OverseerToggle",
    "OverseerRun",
  },
  opts = {},
  config = function(_, opts)
    vim.api.nvim_create_user_command("OverseerRestartLast", function()
      local overseer = require("overseer")
      local tasks = overseer.list_tasks({ recent_first = true })
      if vim.tbl_isempty(tasks) then
        vim.notify("No tasks found", vim.log.levels.WARN)
      else
        overseer.run_action(tasks[1], "restart")
      end
    end, {})

    require("overseer").setup(opts)
    require("overseer").load_template("myplugin.sh")
  end,
  dependencies = {
    "pianocomposer321/officer.nvim",
  },
}
