vim.keymap.set({ "n", "v", "o" }, "<leader>y", '"+y', { noremap = true })
vim.keymap.set({ "n", "v", "o" }, "<leader>Y", '"+Y', { remap = true })

if vim.fn.exists("$SSH_TTY") == 1 then
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      local regs = { "", "+", "*" }
      if vim.v.event.operator == "y" and vim.tbl_contains(regs, vim.v.event.regname) then
        local copy_to_unnamedplus = require("vim.ui.clipboard.osc52").copy("+")
        copy_to_unnamedplus(vim.v.event.regcontents)
        local copy_to_unnamed = require("vim.ui.clipboard.osc52").copy("*")
        copy_to_unnamed(vim.v.event.regcontents)
      end
    end,
  })
end
