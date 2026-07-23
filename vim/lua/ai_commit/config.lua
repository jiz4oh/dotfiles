return {
  model = {
    codex = "gpt-5.4-mini",
    opencode = {
      "openai/gpt-5.4-mini",
      "deepseek/deepseek-v4-flash",
    },
  },
  backend = nil,
  command = nil,
  preferred_commands = { "opencode", "codex" },
  max_title_width = 50,
  body_width = 72,
  reasoning_effort = "low",
  timeout_ms = 10000,
  max_retries = 2,
  spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  spinner_interval = 80,
}
