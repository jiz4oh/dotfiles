local state = require("ai_commit.state")
local config = require("ai_commit.config")
local UI = require("ai_commit.ui")
local cli = require("ai_commit.cli")

local JOB = {}

local retry_after_timeout

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
      UI.notify("Commit message generation timed out", vim.log.levels.WARN)
      retry_after_timeout()
    end)
  end)
end

function JOB.run_job()
  local api = state.api
  local prompt = state.prompt
  local cwd = state.cwd

  if not api or not prompt or not cwd then
    UI.hide_popup()
    UI.notify("Internal state lost", vim.log.levels.ERROR)
    return
  end

  local command, opts = cli.build_openai_invocation(api, prompt, state.model)

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
        return
      end
      if state.timed_out then
        UI.stop_timeout()
        return
      end

      if obj.code ~= 0 then
        UI.stop_spinner()
        UI.stop_timeout()
        UI.set_popup_lines({
          "AI generation failed.",
          "",
          cli.read_openai_error(obj),
        })
        vim.bo[state.popup_buf].modifiable = false
        UI.notify("Commit message generation failed", vim.log.levels.ERROR)
        state.job = nil
        return
      end

      local output, output_err = cli.read_openai_response(obj)
      state.job = nil
      if not output then
        UI.stop_spinner()
        UI.stop_timeout()
        UI.set_popup_lines({ "AI generation failed.", "", output_err })
        vim.bo[state.popup_buf].modifiable = false
        UI.notify("Commit message generation failed", vim.log.levels.ERROR)
        return
      end
      UI.render_result(output)
    end)
  end)
end

retry_after_timeout = function()
  state.total_retries = state.total_retries + 1

  if state.total_retries > config.max_retries then
    UI.render_timeout()
    return
  end

  state.timed_out = false
  state.generation = state.generation + 1
  UI.stop_spinner()
  JOB.run_job()
end

return JOB
