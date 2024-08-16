map <leader>ot :OverseerToggle<CR>
map <leader>or :OverseerRun<CR>

lua<<EOF
vim.api.nvim_create_user_command("OverseerRestartLast", function()
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify("No tasks found", vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], "restart")
  end
end, {})

require('overseer').setup()

require('overseer').load_template("myplugin.sh")
EOF
