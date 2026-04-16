local M = {}

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
}

local config = {
  model = {
    codex = "gpt-5.4-mini",
    opencode = "openai/gpt-5.4-mini",
  },
  backend = nil,
  command = nil,
  preferred_commands = { "opencode", "codex" },
  max_title_width = 50,
  body_width = 72,
  reasoning_effort = "low",
  timeout_ms = 20000,
  spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  spinner_interval = 80,
}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "AICommit" })
end

local function buf_is_valid(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function win_is_valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function cleanup_tempfile()
  if state.temp_output and vim.fn.filereadable(state.temp_output) == 1 then
    vim.fn.delete(state.temp_output)
  end
  state.temp_output = nil
end

local function stop_spinner()
  if state.spinner_timer then
    state.spinner_timer:stop()
    state.spinner_timer:close()
    state.spinner_timer = nil
  end
  state.spinner_index = 1
end

local function stop_timeout()
  if state.timeout_timer then
    state.timeout_timer:stop()
    state.timeout_timer:close()
    state.timeout_timer = nil
  end
end

local function destroy_popup()
  stop_spinner()
  stop_timeout()

  if state.job and state.job.is_closing ~= nil and not state.job:is_closing() then
    state.job:kill(15)
  end

  state.job = nil

  if win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
  end

  if buf_is_valid(state.popup_buf) then
    vim.api.nvim_buf_delete(state.popup_buf, { force = true })
  end

  cleanup_tempfile()

  state.popup_buf = nil
  state.popup_win = nil
  state.backend = nil
end

local function hide_popup()
  stop_spinner()
  stop_timeout()

  if win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
  end

  state.popup_win = nil
end

local function set_popup_lines(lines)
  if not buf_is_valid(state.popup_buf) then
    return
  end

  vim.bo[state.popup_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.popup_buf, 0, -1, false, lines)
  vim.bo[state.popup_buf].modifiable = false
end

local function update_spinner_line()
  if not buf_is_valid(state.popup_buf) then
    stop_spinner()
    return
  end

  local frame = config.spinner_frames[state.spinner_index]
  state.spinner_index = (state.spinner_index % #config.spinner_frames) + 1

  local backend = state.backend or "ai"
  vim.bo[state.popup_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.popup_buf, 0, 1, false, {
    string.format("Generating %s commit message... %s", backend, frame),
  })
  vim.bo[state.popup_buf].modifiable = false
end

local function start_spinner()
  stop_spinner()
  update_spinner_line()

  state.spinner_timer = vim.uv.new_timer()
  state.spinner_timer:start(config.spinner_interval, config.spinner_interval, function()
    vim.schedule(update_spinner_line)
  end)
end

local function render_timeout()
  stop_spinner()
  stop_timeout()

  if not buf_is_valid(state.popup_buf) then
    return
  end

  set_popup_lines({
    string.format("Timed out after %.1fs.", config.timeout_ms / 1000),
    "",
    "Commit message generation was cancelled.",
    "Try again or reduce the staged diff size.",
    "",
    "Keys:",
    "  q hide popup",
  })
  vim.bo[state.popup_buf].modifiable = false
end

local function start_timeout()
  stop_timeout()
  state.timed_out = false
  state.timeout_timer = vim.uv.new_timer()
  state.timeout_timer:start(config.timeout_ms, 0, function()
    vim.schedule(function()
      if not state.job then
        stop_timeout()
        return
      end

      state.timed_out = true
      if state.job.is_closing ~= nil and not state.job:is_closing() then
        state.job:kill(15)
      end
      state.job = nil
      cleanup_tempfile()
      render_timeout()
      notify("Commit message generation timed out", vim.log.levels.WARN)
    end)
  end)
end

local function create_popup_window()
  local width = math.min(math.max(math.floor(vim.o.columns * 0.6), 60), 100)
  local height = math.min(math.max(math.floor(vim.o.lines * 0.4), 10), 18)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  state.popup_win = vim.api.nvim_open_win(state.popup_buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    title = " AI Commit ",
    title_pos = "center",
    width = width,
    height = height,
    row = math.max(row, 1),
    col = col,
  })

  vim.wo[state.popup_win].wrap = true
  vim.wo[state.popup_win].linebreak = true
  vim.wo[state.popup_win].winfixbuf = true

  vim.keymap.set("n", "q", hide_popup, { buffer = state.popup_buf, silent = true })
end

local function open_popup(target_buf, target_win, backend)
  destroy_popup()

  state.target_buf = target_buf
  state.target_win = target_win
  state.backend = backend
  state.popup_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.popup_buf].buftype = "nofile"
  vim.bo[state.popup_buf].bufhidden = "hide"
  vim.bo[state.popup_buf].swapfile = false
  vim.bo[state.popup_buf].filetype = "gitcommit"

  create_popup_window()

  set_popup_lines({
    string.format("Generating %s commit message...", state.backend or "ai"),
    "",
    "Keys:",
    "  <C-y> apply to current gitcommit buffer",
    "  q hide popup",
  })
  start_spinner()
  start_timeout()
end

local function normalize_message(raw)
  local lines = vim.split(raw or "", "\n", { plain = true, trimempty = false })
  local cleaned = {}
  local in_codeblock = false

  for _, line in ipairs(lines) do
    if line:match("^```") then
      in_codeblock = not in_codeblock
    elseif in_codeblock or line ~= "" or #cleaned > 0 then
      table.insert(cleaned, (line:gsub("%s+$", "")))
    end
  end

  while #cleaned > 0 and cleaned[#cleaned] == "" do
    table.remove(cleaned)
  end

  return cleaned
end

local function apply_message()
  if not buf_is_valid(state.popup_buf) or not buf_is_valid(state.target_buf) then
    destroy_popup()
    notify("Target gitcommit buffer is gone", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(state.popup_buf, 0, -1, false)
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end

  vim.bo[state.target_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.target_buf, 0, -1, false, lines)
  vim.bo[state.target_buf].modified = true

  if win_is_valid(state.target_win) then
    vim.api.nvim_set_current_win(state.target_win)
  end

  hide_popup()
end

local function set_confirm_maps()
  vim.keymap.set("n", "<C-y>", apply_message, { buffer = state.popup_buf, silent = true })
end

local function get_repo_cwd()
  if vim.b.git_dir and vim.b.git_dir ~= "" then
    return vim.fn.fnamemodify(vim.b.git_dir, ":h")
  end

  local cwd = vim.fn.getcwd()
  local git_dir = vim.fs.find(".git", { upward = true, path = cwd })[1]
  if git_dir then
    return vim.fn.fnamemodify(git_dir, ":h")
  end

  return cwd
end

local function get_staged_diff(cwd)
  local result = vim
    .system({ "git", "diff", "--staged", "--no-ext-diff" }, {
      cwd = cwd,
      text = true,
    })
    :wait()

  if result.code ~= 0 then
    return nil, (result.stderr or ""):gsub("%s+$", "")
  end

  if not result.stdout or result.stdout == "" then
    return nil, "No staged diff found"
  end

  return result.stdout, nil
end

local function build_prompt(diff)
  return table.concat({
    "Write a conventional commit message for this staged diff.",
    string.format("Subject: under %d chars.", config.max_title_width),
    string.format("Body: wrap at %d chars when needed.", config.body_width),
    "Return only the commit message text.",
    "",
    "<staged_diff>",
    diff,
    "</staged_diff>",
    "",
  }, "\n")
end

local function render_result(raw)
  stop_spinner()
  stop_timeout()
  local lines = normalize_message(raw)

  if #lines == 0 then
    lines = { "" }
  end

  set_popup_lines(lines)
  set_confirm_maps()

  if win_is_valid(state.popup_win) then
    vim.api.nvim_set_current_win(state.popup_win)
  end
end

local function infer_backend(command)
  local name = vim.fs.basename(command)
  if name == "opencode" then
    return "opencode"
  end
  if name == "codex" then
    return "codex"
  end
  return nil
end

local function resolve_cli()
  if config.command then
    if vim.fn.executable(config.command) ~= 1 then
      return nil, string.format("Configured AI CLI '%s' is not available in PATH", config.command)
    end

    local backend = config.backend or infer_backend(config.command)
    if not backend then
      return nil, "Unable to infer AI CLI backend; set setup({ backend = 'opencode' | 'codex' })"
    end

    return { command = config.command, backend = backend }, nil
  end

  for _, command in ipairs(config.preferred_commands) do
    if vim.fn.executable(command) == 1 then
      local backend = infer_backend(command)
      if backend then
        return { command = command, backend = backend }, nil
      end
    end
  end

  return nil, "No supported AI CLI found in PATH (tried: opencode, codex)"
end

local function normalize_reasoning_effort(backend)
  local effort = config.reasoning_effort
  if not effort or effort == "" then
    return nil
  end

  local maps = {
    codex = {
      minimal = "low",
      low = "low",
      medium = "medium",
      high = "high",
      max = "high",
    },
    opencode = {
      low = "minimal",
      minimal = "minimal",
      medium = "medium",
      high = "high",
      max = "max",
    },
  }

  return (maps[backend] and maps[backend][effort]) or effort
end

local function resolve_model(backend)
  if type(config.model) == "table" then
    return config.model[backend]
  end

  if type(config.model) == "string" and config.model ~= "" then
    return config.model
  end

  return nil
end

local function build_cli_invocation(cli, prompt)
  if cli.backend == "codex" then
    state.temp_output = vim.fn.tempname()

    local command = {
      cli.command,
      "exec",
      "--ephemeral",
      "--skip-git-repo-check",
      "--color",
      "never",
      "-s",
      "read-only",
    }
    local effort = normalize_reasoning_effort("codex")
    if effort then
      vim.list_extend(command, { "-c", string.format('model_reasoning_effort="%s"', effort) })
    end
    local model = resolve_model("codex")
    if model then
      vim.list_extend(command, { "-m", model })
    end
    vim.list_extend(command, { "-o", state.temp_output, "-" })

    return command, {
      text = true,
      stdin = prompt,
    }
  end

  if cli.backend == "opencode" then
    local command = {
      cli.command,
      "run",
      "--format",
      "json",
      "--pure",
    }
    local model = resolve_model("opencode")
    if model then
      vim.list_extend(command, { "-m", model })
    end

    local effort = normalize_reasoning_effort("opencode")
    if effort then
      vim.list_extend(command, { "--variant", effort })
    end

    return command, {
      text = true,
      stdin = prompt,
      env = vim.tbl_extend("force", vim.fn.environ(), {
        OPENCODE_CONFIG_CONTENT = '{"permission":{"edit":"deny","bash":"deny"}}',
      }),
    }
  end

  return nil, nil
end

local function parse_opencode_json_output(raw)
  local lines = vim.split(raw or "", "\n", { plain = true, trimempty = true })
  local chunks = {}

  for _, line in ipairs(lines) do
    local ok, decoded = pcall(vim.json.decode, line)
    if ok and type(decoded) == "table" and decoded.type == "text" then
      local part = decoded.part
      if type(part) == "table" and type(part.text) == "string" and part.text ~= "" then
        table.insert(chunks, part.text)
      end
    end
  end

  return table.concat(chunks, "\n")
end

local function read_cli_output(cli, obj)
  if cli.backend == "codex" then
    local output = {}
    if state.temp_output and vim.fn.filereadable(state.temp_output) == 1 then
      output = vim.fn.readfile(state.temp_output)
    end
    cleanup_tempfile()
    return table.concat(output, "\n")
  end

  cleanup_tempfile()

  if cli.backend == "opencode" then
    local parsed = parse_opencode_json_output(obj.stdout or "")
    if parsed ~= "" then
      return parsed
    end
  end

  return obj.stdout or ""
end

function M.reopen_popup()
  if not buf_is_valid(state.popup_buf) then
    notify("No existing commit popup", vim.log.levels.WARN)
    return
  end

  if win_is_valid(state.popup_win) then
    vim.api.nvim_set_current_win(state.popup_win)
    return
  end

  local target_buf = buf_is_valid(state.target_buf) and state.target_buf
      or vim.api.nvim_get_current_buf()
  local target_win = win_is_valid(state.target_win) and state.target_win
      or vim.api.nvim_get_current_win()
  create_popup_window()
end

function M.generate()
  local target_buf = vim.api.nvim_get_current_buf()
  local target_win = vim.api.nvim_get_current_win()

  if vim.bo[target_buf].filetype ~= "gitcommit" then
    notify("GitCommit works in gitcommit buffers", vim.log.levels.WARN)
    return
  end

  local cli, cli_err = resolve_cli()
  if not cli then
    notify(cli_err, vim.log.levels.ERROR)
    return
  end

  local cwd = get_repo_cwd()
  local diff, diff_err = get_staged_diff(cwd)
  if not diff then
    notify(diff_err, vim.log.levels.WARN)
    return
  end

  state.backend = cli.backend
  open_popup(target_buf, target_win, cli.backend)

  local prompt = build_prompt(diff)
  local command, opts = build_cli_invocation(cli, prompt)
  if not command or not opts then
    hide_popup()
    notify("Unsupported AI CLI backend", vim.log.levels.ERROR)
    return
  end

  state.job = vim.system(command, vim.tbl_extend("force", opts, {
    cwd = cwd,
  }), function(obj)
    vim.schedule(function()
      if not buf_is_valid(state.popup_buf) then
        stop_timeout()
        cleanup_tempfile()
        return
      end

      if state.timed_out then
        stop_timeout()
        cleanup_tempfile()
        return
      end

      if obj.code ~= 0 then
        stop_spinner()
        stop_timeout()
        local err = obj.stderr and obj.stderr:gsub("%s+$", "") or ""
        set_popup_lines({
          "AI CLI generation failed.",
          "",
          err ~= "" and err or ("Exit code: " .. obj.code),
        })
        vim.bo[state.popup_buf].modifiable = false
        notify("Commit message generation failed", vim.log.levels.ERROR)
        cleanup_tempfile()
        state.job = nil
        return
      end

      local output = read_cli_output(cli, obj)
      state.job = nil
      render_result(output)
    end)
  end)
end

function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
end

return M
