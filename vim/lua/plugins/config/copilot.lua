---@type LazyPluginSpec
return {
  "zbirenbaum/copilot.lua",
  enabled = vim.fn.has("nvim-0.10") == 1,
  event = "InsertEnter",
  cmd = "Copilot",
  opts = {
    -- suggestion = { enabled = false },
    -- panel = { enabled = false },
    copilot_node_command = vim.g.node_path
  },
}
