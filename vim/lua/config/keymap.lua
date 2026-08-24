vim.keymap.set("n", "<leader>R", "<cmd>restart<cr>", { desc = "Restart Neovim" })

vim.keymap.set("n", "gof", function()
  vim.ui.open(vim.fn.expand("%:p"))
end)

vim.keymap.set("n", "goF", function()
  vim.ui.open(vim.fn.getcwd())
end)
