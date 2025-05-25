local files = require("overseer.files")

local pattern = vim.regex([[^\(docker-\)\?compose\(\.[a-zA-Z0-9_-]\+\)*\.ya\?ml$]]) -- Equivalent without very magic

---@type overseer.TemplateDefinition
return {
  name = "docker compose ",
  priority = 60,
  params = function()
    local stdout = vim.system({ "docker", "compose", "ls", "--format", "json" }):wait().stdout
    local projects = {}
    ---@diagnostic disable-next-line: param-type-mismatch
    for _, v in ipairs(vim.json.decode(stdout)) do
      table.insert(projects, v.Name)
    end

    ---@diagnostic disable-next-line: undefined-field
    local all_files = files.list_files(vim.loop.cwd())
    local filtered = vim.tbl_filter(function(filename)
      local matched = pattern:match_str(filename)
      return matched ~= nil
    end, all_files)
    local default
    local file_choices

    if #filtered > 0 then
      file_choices = filtered
      default = filtered[1]
    else
      file_choices = {
        "compose.yaml",
        "compose.yml",
        "docker-compose.yaml",
        "docker-compose.yml",
      }
    end

    return {
      cmd = {
        desc = "Action",
        type = "enum",
        choices = {
          "build",
          "logs",
          "create",
          "down",
          "images",
          "kill",
          "pause",
          "ps",
          "ls",
          "pull",
          "rm",
          "start",
          "stop",
          "top",
          "unpause",
          "up",
        },
        order = 1,
      },
      args = {
        type = "list",
        delimiter = " ",
        order = 2,
        optional = true,
      },
      project = {
        desc = "Which project to use",
        type = "enum",
        order = 3,
        choices = projects,
        optional = true,
      },
      file = {
        desc = "Name of docker-compose file",
        type = "enum",
        choices = file_choices,
        default = default,
        optional = true,
        order = 4,
      },
    }
  end,
  builder = function(params)
    local args = {}

    if params.project then
      table.insert(args, "-p")
      table.insert(args, params.project)
    end

    if params.file then
      table.insert(args, "-f")
      table.insert(args, params.file)
    end

    if params.cmd then
      table.insert(args, params.cmd)
    end

    for _, v in ipairs(params.args or {}) do
      table.insert(args, v)
    end

    ---@type overseer.TaskDefinition
    local task_def = {
      cmd = { "docker", "compose" },
      args = args,
      components = {
        "dispatch",
      },
    }

    return task_def
  end,
}
