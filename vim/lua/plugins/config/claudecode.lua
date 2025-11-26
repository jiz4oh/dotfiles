local claude_terminal_bufnr
local term_name = "claudecode"

local open = function(cmd_string, env_table, effective_config, focus)
  focus = focus == nil and true or focus

  -- Build environment variables string
  local env_str = ""
  if env_table and next(env_table) ~= nil then
    for key, value in pairs(env_table) do
      env_str = env_str .. key .. "='" .. value .. "' "
    end
  end

  -- Create the full command
  local full_cmd = env_str .. (cmd_string or "")

  -- Open floaterm with the command
  vim.cmd("FloatermNew --name=" .. term_name .. " --width=0.8 --height=0.8 --position=center --title=ClaudeTerminal " .. full_cmd)

  claude_terminal_bufnr = vim.api.nvim_get_current_buf()

  return true
end

local is_active = function()
  return claude_terminal_bufnr and vim.api.nvim_buf_is_valid(claude_terminal_bufnr)
end

---@type LazyPluginSpec
return {
  "coder/claudecode.nvim",
  optional = true,
  opts = {
    -- Server Configuration
    port_range = { min = 10000, max = 65535 },
    auto_start = true,
    log_level = "info", -- "trace", "debug", "info", "warn", "error"
    terminal_cmd = nil, -- Custom terminal command (default: "claude")

    -- Selection Tracking
    track_selection = true,
    visual_demotion_delay_ms = 50,

    -- Terminal Configuration with vim-floaterm
    terminal = {
      provider = {
        -- Initialize the terminal provider
        setup = function(config)
          -- Ensure vim-floaterm is available
          if vim.fn.exists(":FloatermNew") ~= 2 then
            vim.notify("vim-floaterm not found, please install vim-floaterm", vim.log.levels.ERROR)
            return false
          end
          return true
        end,

        -- Open terminal with command
        open = open,

        close = function()
          if is_active() then
            vim.cmd("FloatermKill " .. term_name)
            term_name = nil
            claude_terminal_bufnr = nil
          end
        end,

        simple_toggle = function(cmd_string, env_table, effective_config)
          if is_active() then
            vim.cmd("FloatermToggle")
          else
            open(cmd_string, env_table, effective_config)
          end
        end,

        -- Focus toggle with smart behavior
        focus_toggle = function(cmd_string, env_table, effective_config)
          local b = vim.api.nvim_get_current_buf()

          if not is_active() then
            open(cmd_string, env_table, effective_config)
          elseif b == claude_terminal_bufnr then
            vim.cmd("FloatermHide " .. term_name)
          else
            vim.cmd("FloatermShow " .. term_name)
          end
        end,

        get_active_bufnr = function()
          return claude_terminal_bufnr
        end,
        is_available = function()
          return vim.fn.exists(":FloatermNew") == 2
        end,
      },
    },

    -- Diff Integration
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
      open_in_current_tab = true,
    },
  },
  cmd = {
    "ClaudeCode",
  },
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<c-,>", "<cmd>ClaudeCodeFocus<cr>", mode = { "t", "n" }, desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
