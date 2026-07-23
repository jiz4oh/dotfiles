local state = require("ai_commit.state")
local config = require("ai_commit.config")

local CLI = {}

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

function CLI.resolve_models(backend)
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

function CLI.read_cli_output(cli, obj)
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
