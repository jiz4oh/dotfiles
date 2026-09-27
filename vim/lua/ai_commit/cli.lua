local config = require("ai_commit.config")

local CLI = {}

function CLI.resolve_openai()
  local base_url = os.getenv("OPENAI_BASE_URL")
  local api_key = os.getenv("OPENAI_API_KEY")
  if not base_url or base_url == "" or not api_key or api_key == "" then
    return nil, "OpenAI Chat Completions API requires OPENAI_BASE_URL and OPENAI_API_KEY"
  end
  if api_key:find("[\r\n]") then
    return nil, "OPENAI_API_KEY must not contain line breaks"
  end

  local command = vim.fn.exepath("curl")
  if command == "" then
    return nil, "OpenAI Chat Completions API requires curl in PATH"
  end

  local resolved = {
    command = command,
    endpoint = base_url:gsub("/+$", "") .. "/chat/completions",
  }
  return resolved, nil
end

function CLI.get_model()
  local model = os.getenv("OPENAI_MODEL")
  if model and model ~= "" then
    return model
  end
  return config.model
end

function CLI.build_openai_invocation(api, prompt, model)
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

  return { "/bin/sh", "-c", script, "ai-commit-openai", api.command, api.endpoint }, {
    text = true,
    stdin = payload,
  }
end

local function parse_chat_completions_output(raw)
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

function CLI.read_openai_error(obj)
  if obj.stdout and obj.stdout ~= "" then
    local ok, decoded = pcall(vim.json.decode, obj.stdout)
    local err = ok and type(decoded) == "table" and decoded.error or nil
    if type(err) == "table" and type(err.message) == "string" then
      return err.message
    end
  end

  local stderr = obj.stderr and obj.stderr:gsub("%s+$", "") or ""
  return stderr ~= "" and stderr or ("Exit code: " .. obj.code)
end

function CLI.read_openai_response(obj)
  return parse_chat_completions_output(obj.stdout)
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
