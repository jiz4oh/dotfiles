local enabled = vim.g.as_ide == 1 and vim.fn.has("nvim-0.10") == 1

---@type LazySpec[]
return {
  {
    "coder/claudecode.nvim",
    enabled = enabled,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = enabled,
    import = "plugins.config.CopilotChat",
  },
}
