local state = require("ai_commit.state")
local config = require("ai_commit.config")
local UI = require("ai_commit.ui")
local cli = require("ai_commit.cli")

local JOB = {}

local retry_next_model

local function start_timeout()
  UI.stop_timeout()
  state.timed_out = false
  state.timeout_timer = vim.uv.new_timer()
  state.timeout_timer:start(config.timeout_ms, 0, function()
    vim.schedule(function()
      if not state.job then
        UI.stop_timeout()
        return
      end

      state.timed_out = true
      local job = state.job
      state.job = nil
      if job and job.is_closing ~= nil and not job:is_closing() then
        job:kill(15)
      end
      state.cleanup_tempfile()
      UI.notify("Commit message generation timed out", vim.log.levels.WARN)
      retry_next_model()
    end)
  end)
end

function JOB.run_job_for_current_model()
  local cli_obj = state.cli
  local prompt = state.prompt
  local cwd = state.cwd

  if not cli_obj or not prompt or not cwd then
    UI.hide_popup()
    UI.notify("Internal state lost", vim.log.levels.ERROR)
    return
  end

  local model = cli.get_current_model()
  local command, opts = cli.build_cli_invocation(cli_obj, prompt, model)
  if not command or not opts then
    UI.hide_popup()
    UI.notify("Unsupported AI CLI backend", vim.log.levels.ERROR)
    return
  end

  UI.start_spinner()
  start_timeout()

  local gen = state.generation
  state.job = vim.system(command, vim.tbl_extend("force", opts, {
    cwd = cwd,
  }), function(obj)
    vim.schedule(function()
      if gen ~= state.generation then
        return
      end
      if not UI.buf_is_valid(state.popup_buf) then
        UI.stop_timeout()
        state.cleanup_tempfile()
        return
      end
      if state.timed_out then
        UI.stop_timeout()
        state.cleanup_tempfile()
        return
      end

      if obj.code ~= 0 then
        UI.stop_spinner()
        UI.stop_timeout()
        local err = obj.stderr and obj.stderr:gsub("%s+$", "") or ""
        UI.set_popup_lines({
          "AI CLI generation failed.",
          "",
          err ~= "" and err or ("Exit code: " .. obj.code),
        })
        vim.bo[state.popup_buf].modifiable = false
        UI.notify("Commit message generation failed", vim.log.levels.ERROR)
        state.cleanup_tempfile()
        state.job = nil
        return
      end

      local output = cli.read_cli_output(cli_obj, obj)
      state.job = nil
      UI.render_result(output)
    end)
  end)
end

retry_next_model = function()
  state.retry_count = state.retry_count + 1
  state.total_retries = state.total_retries + 1

  if state.retry_count > config.max_retries then
    state.model_index = state.model_index + 1
    state.retry_count = 0
  end

  if #state.model_list == 0 or state.model_index >= #state.model_list then
    UI.render_timeout()
    return
  end

  state.timed_out = false
  state.generation = state.generation + 1
  UI.stop_spinner()
  state.cleanup_tempfile()
  JOB.run_job_for_current_model()
end

return JOB
