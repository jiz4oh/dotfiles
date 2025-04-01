local lazy = true

local patterns = { "ssh", "scp", "sftp", "docker" }
if vim.fn.argc() > 0 then
  for _, file in ipairs(vim.fn.argv()) do
    for _, pattern in ipairs(patterns) do
      if file:match(pattern .. "://") then
        lazy = false
        break
      end
    end
  end
end

---@type LazyPluginSpec
return {
  "miversen33/netman.nvim",
  cmd = {
    "NmloadProvider",
    "Nmlogs",
    "Nmdelete",
    "Nmread",
    "Nmwrite",
  },
  init = function()
    vim.g.disable_netrw = 1
  end,
  lazy = lazy,
  opts = {},
}
