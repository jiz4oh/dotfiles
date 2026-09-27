return {
  model = os.getenv("OPENAI_MODEL") or "gpt-5.6-luna",
  max_title_width = 50,
  body_width = 72,
  timeout_ms = 10000,
  max_retries = 2,
  spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  spinner_interval = 80,
}
