local state = require("ai_commit.state")
local config = require("ai_commit.config")
local UI = require("ai_commit.ui")
local cli = require("ai_commit.cli")
local JOB = require("ai_commit.job")

local M = {}

function M.reopen_popup()
  if not UI.buf_is_valid(state.popup_buf) then
    UI.notify("No existing commit popup", vim.log.levels.WARN)
    return
  end

  if UI.win_is_valid(state.popup_win) then
    vim.api.nvim_set_current_win(state.popup_win)
    return
  end

  local target_buf = UI.buf_is_valid(state.target_buf) and state.target_buf
      or vim.api.nvim_get_current_buf()
  local target_win = UI.win_is_valid(state.target_win) and state.target_win
      or vim.api.nvim_get_current_win()
  UI.create_popup_window()
end

function M.generate()
  local target_buf = vim.api.nvim_get_current_buf()
  local target_win = vim.api.nvim_get_current_win()

  if vim.bo[target_buf].filetype ~= "gitcommit" then
    UI.notify("GitCommit works in gitcommit buffers", vim.log.levels.WARN)
    return
  end

  local resolved_cli, cli_err = cli.resolve_cli()
  if not resolved_cli then
    UI.notify(cli_err, vim.log.levels.ERROR)
    return
  end

  local cwd = cli.get_repo_cwd()
  local diff, diff_err = cli.get_staged_diff(cwd)
  if not diff then
    UI.notify(diff_err, vim.log.levels.WARN)
    return
  end

  state.backend = resolved_cli.backend
  state.cli = resolved_cli
  state.prompt = cli.build_prompt(diff)
  state.cwd = cwd
  state.model_list = cli.resolve_models(resolved_cli.backend)
  state.model_index = 0
  state.retry_count = 0
  state.total_retries = 0
  state.generation = state.generation + 1

  UI.open_popup(target_buf, target_win, resolved_cli.backend)
  JOB.run_job_for_current_model()
end

function M.setup(opts)
  if opts then
    for k, v in pairs(opts) do
      config[k] = v
    end
  end
end

return M
