vim.keymap.set({ "n", "v", "o" }, "<leader>y", '"+y', { noremap = true })
vim.keymap.set({ "n", "v", "o" }, "<leader>Y", '"+Y', { remap = true })

vim.keymap.set("n", "<leader>yp", function()
  vim.fn.setreg("+", vim.fn.getcwd())
end, { desc = "Copy current working directory" })

vim.keymap.set("n", "<leader>y%", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy current working directory" })

vim.keymap.set("n", "<leader>yr", function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
  vim.fn.setreg("+", path)
end, { desc = "Copy relative file path" })
