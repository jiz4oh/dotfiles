---@type LazyPluginSpec
return {
  "zbirenbaum/copilot.lua",
  enabled = vim.fn.has("nvim-0.10") == 1,
  event = "InsertEnter",
  cmd = "Copilot",
  opts = {
    -- suggestion = { enabled = false },
    -- panel = { enabled = false },
    copilot_node_command = vim.fn.expand("$ASDF_DIR") .. "/installs/nodejs/20.10.0/bin/node",
  },
}
