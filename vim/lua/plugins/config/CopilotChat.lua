---@type LazyPluginSpec
return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim" },
  },
  cmd = {
    "CopilotChat",
    "CopilotChatModels",
    "CopilotChatAgents",
    "CopilotChatCommit",
    "CopilotChatToggle",
  },
  keys = {
    { "cc", "<cmd>CopilotChatCommit<cr>", ft = "gitcommit", desc = "Genearate commit message" },
  },
  branch = "main",
  build = "make tiktoken", -- Only on MacOS or Linux
  opts = function()
    local user = vim.env.USER or "User"
    user = user:sub(1, 1):upper() .. user:sub(2)

    return {
      auto_insert_mode = true,
      question_header = "  " .. user .. " ",
      answer_header = "  Copilot ",
      model = vim.g.copilot_model or "gpt-40-2024-08-06",
      chat_autocomplete = true,
      mappings = {
        complete = {
          insert = "",
        },
      },
      window = {
        layout = "float",
        relative = "cursor",
        width = 0.4, -- Changed from 1 to 0.4 (40% of screen width)
        height = 0.4,
        row = 1,
      },
    }
  end,
}
