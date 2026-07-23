local state = {
  popup_buf = nil,
  popup_win = nil,
  target_buf = nil,
  target_win = nil,
  backend = nil,
  temp_output = nil,
  job = nil,
  spinner_timer = nil,
  spinner_index = 1,
  timeout_timer = nil,
  timed_out = false,
  generation = 0,
  model_index = 0,
  model_list = nil,
  retry_count = 0,
  total_retries = 0,
  cli = nil,
  prompt = nil,
  cwd = nil,
}

function state.cleanup_tempfile()
  if state.temp_output and vim.fn.filereadable(state.temp_output) == 1 then
    vim.fn.delete(state.temp_output)
  end
  state.temp_output = nil
end

return state
