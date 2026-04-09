if vim.fn.has("wsl") == 1 then
  if vim.fn.executable("win32yank.exe") == 1 then
    vim.g.clipboard = {
      name = "WslClipboard",
      copy = {
        ["+"] = "win32yank.exe -i --crlf",
        ["*"] = "win32yank.exe -i --crlf",
      },
      paste = {
        ["+"] = "win32yank.exe -o --lf",
        ["*"] = "win32yank.exe -o --lf",
      },
      cache_enabled = 0,
    }

    vim.opt.clipboard = "unnamedplus"
  end
end

if vim.fn.has("nvim-0.11") == 1 then
  vim.o.winborder = "rounded"
end

vim.F.is_ssh_session = function()
  return (vim.env.SSH_TTY ~= nil and vim.env.SSH_TTY ~= "")
    or (vim.env.SSH_CONNECTION ~= nil and vim.env.SSH_CONNECTION ~= "")
    or (vim.env.SSH_CLIENT ~= nil and vim.env.SSH_CLIENT ~= "")
end

vim.F.has_words_before = function()
  local unpack_fn = unpack or table.unpack
  local line, col = unpack_fn(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
