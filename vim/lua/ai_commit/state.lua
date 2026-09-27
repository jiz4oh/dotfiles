local state = {
  popup_buf = nil,
  popup_win = nil,
  target_buf = nil,
  target_win = nil,
  api = nil,
  model = nil,
  job = nil,
  spinner_timer = nil,
  spinner_index = 1,
  timeout_timer = nil,
  timed_out = false,
  generation = 0,
  total_retries = 0,
  prompt = nil,
  cwd = nil,
}

return state
