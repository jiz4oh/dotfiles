local state = require("ai_commit.state")
local config = require("ai_commit.config")

local CLI = {}

local function resolve_openai()
  local base_url = os.getenv("OPENAI_BASE_URL")
  local api_key = os.getenv("OPENAI_API_KEY")
  if not base_url or base_url == "" or not api_key or api_key == "" then
    return nil, "OpenAI backend requires OPENAI_BASE_URL and OPENAI_API_KEY"
  end
  if api_key:find("[\r\n]") then
    return nil, "OPENAI_API_KEY must not contain line breaks"
  end

  local command = vim.fn.exepath("curl")
  if command == "" then
    return nil, "OpenAI backend requires curl in PATH"
  end

  local resolved = {
    command = command,
    backend = "openai",
    endpoint = base_url:gsub("/+$", "") .. "/chat/completions",
  }
  return resolved, nil
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

function CLI.resolve_cli()
  if config.backend == "openai" then
    return resolve_openai()
  end

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

  for _, backend in ipairs(config.preferred_backends) do
    if backend == "openai" then
      local resolved = resolve_openai()
      if resolved then
        return resolved, nil
      end
    else
      for _, command in ipairs(config.preferred_commands) do
        if infer_backend(command) == backend and vim.fn.executable(command) == 1 then
          return { command = command, backend = backend }, nil
        end
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

function CLI.resolve_models(backend)
  if backend == "openai" then
    local model = os.getenv("OPENAI_MODEL")
    if model and model ~= "" then
      return { model }
    end
  end

  if type(config.model) == "string" and config.model ~= "" then
    return { config.model }
  end

  if type(config.model) ~= "table" then
    return {}
  end

  local v = config.model[backend]
  if v then
    if type(v) == "table" and v[1] then
      return v
    end
    if type(v) == "string" and v ~= "" then
      return { v }
    end
    return {}
  end

  if config.model[1] then
    return config.model
  end

  return {}
end

function CLI.get_current_model()
  local list = state.model_list
  if not list then
    return nil
  end
  return list[state.model_index + 1]
end

function CLI.build_cli_invocation(cli, prompt, model)
  if cli.backend == "openai" then
    local payload = vim.json.encode({
      model = model,
      messages = { { role = "user", content = prompt } },
      stream = false,
    })
    local script = table.concat({
      "exec 3<&0",
      [[printf '%s\n' 'Content-Type: application/json' "Authorization: Bearer $OPENAI_API_KEY" |]],
      [[exec "$1" --silent --show-error --fail-with-body --header @- --data-binary @/dev/fd/3 "$2"]],
    }, "\n")

    return { "/bin/sh", "-c", script, "ai-commit-openai", cli.command, cli.endpoint }, {
      text = true,
      stdin = payload,
    }
  end

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

local function parse_openai_json_output(raw)
  local ok, decoded = pcall(vim.json.decode, raw or "")
  if not ok or type(decoded) ~= "table" then
    return nil, "OpenAI-compatible API returned invalid JSON"
  end

  local choice = type(decoded.choices) == "table" and decoded.choices[1] or nil
  local message = type(choice) == "table" and choice.message or nil
  local content = type(message) == "table" and message.content or nil
  if type(content) ~= "string" or content == "" then
    return nil, "OpenAI-compatible API response is missing choices[0].message.content"
  end

  return content, nil
end

function CLI.read_error(cli, obj)
  if cli.backend == "openai" and obj.stdout and obj.stdout ~= "" then
    local ok, decoded = pcall(vim.json.decode, obj.stdout)
    local err = ok and type(decoded) == "table" and decoded.error or nil
    if type(err) == "table" and type(err.message) == "string" then
      return err.message
    end
  end

  local stderr = obj.stderr and obj.stderr:gsub("%s+$", "") or ""
  return stderr ~= "" and stderr or ("Exit code: " .. obj.code)
end

function CLI.read_cli_output(cli, obj)
  if cli.backend == "openai" then
    state.cleanup_tempfile()
    return parse_openai_json_output(obj.stdout)
  end

  if cli.backend == "codex" then
    local output = {}
    if state.temp_output and vim.fn.filereadable(state.temp_output) == 1 then
      output = vim.fn.readfile(state.temp_output)
    end
    state.cleanup_tempfile()
    return table.concat(output, "\n")
  end

  state.cleanup_tempfile()

  if cli.backend == "opencode" then
    local parsed = parse_opencode_json_output(obj.stdout or "")
    if parsed ~= "" then
      return parsed
    end
  end

  return obj.stdout or ""
end

function CLI.get_repo_cwd()
  if vim.b.git_dir and vim.b.git_dir ~= "" then
    if vim.fn.exists("*FugitiveWorkTree") == 1 then
      local worktree = vim.fn.FugitiveWorkTree(vim.b.git_dir)
      if worktree and worktree ~= "" then
        return worktree
      end
    end

    return vim.fn.fnamemodify(vim.b.git_dir, ":h")
  end

  local cwd = vim.fn.getcwd()
  local git_dir = vim.fs.find(".git", { upward = true, path = cwd })[1]
  if git_dir then
    return vim.fn.fnamemodify(git_dir, ":h")
  end

  return cwd
end

function CLI.get_staged_diff(cwd)
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

function CLI.build_prompt(diff)
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

return CLI
