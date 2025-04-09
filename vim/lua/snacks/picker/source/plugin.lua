local M = {}

---@type snacks.picker.finder
function M.plugin()
  local items = {}
  for name, plugin in pairs(require("lazy.core.config").plugins) do
    table.insert(items, {
      text = name,
      data = vim.inspect(plugin["_"]),
      preview = {
        text = vim.inspect(plugin["_"]),
        ft = "lua",
      },
    })
  end
  return items
end

return M
