---@type LazyPluginSpec
return {
  "aznhe21/actions-preview.nvim",
  optional = true,
  opts = {},
  config = function()
    vim.keymap.set({ "v", "n" }, "<leader>la", require("actions-preview").code_actions)
  end,
}
