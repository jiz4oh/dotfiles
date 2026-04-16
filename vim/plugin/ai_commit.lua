local m = require("ai_commit")

m.setup()

vim.api.nvim_create_user_command("GitCommit", function()
  m.generate()
end, {
  desc = "Generate commit message with AI CLI",
})

vim.api.nvim_create_user_command("GitCommitPopup", function()
  m.reopen_popup()
end, {
  desc = "Reopen the last AI commit popup",
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ai_commit_keymap", { clear = true }),
  pattern = "gitcommit",
  callback = function(args)
    vim.keymap.set("n", "cc", "<cmd>GitCommit<cr>", {
      buffer = args.buf,
      silent = true,
      desc = "Generate commit message",
    })
  end,
})
