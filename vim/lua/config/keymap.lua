vim.keymap.set("n", "<leader>R", function()
  vim.notify("Neovim restarting!", vim.log.levels.INFO)

  local session = vim.fn.stdpath("state") .. "/restart_session.vim"
  vim.cmd("mksession! " .. vim.fn.fnameescape(session))
  vim.cmd("restart source " .. vim.fn.fnameescape(session))
end)

vim.keymap.set("n", "gof", function()
  vim.ui.open(vim.fn.expand("%:p"))
end)

vim.keymap.set("n", "goF", function()
  vim.ui.open(vim.fn.getcwd())
end)
