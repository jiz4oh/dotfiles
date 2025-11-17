local cmds = {
  "start",
  "stop",
  "exec",
  "restart",
  "rm",
  "logs",
  "inspect",
  "top",
  "stats",
  "attach",
  -- "cp", -- complicated by the fact that it can be used to copy files
  "diff",
  "pause",
  "unpause",
  "wait",
  "port",
  "rename",
  "update",
  "commit",
}

---@type overseer.TemplateDefinition
return {
  name = "docker ",
  params = function() -- https://github.com/stevearc/overseer.nvim/issues/86
    local stdout = vim.system({ "docker", "ps", "--format", "{{lower .Names}}" }):wait().stdout
    local containers = vim.split(stdout or "", "\n", { trimempty = true })
    return {
      cmd = {
        desc = "Docker command (e.g., build, run, ps, images)",
        type = "list",
        delimiter = " ",
        order = 1,
      },
      container = {
        desc = "Which container to use",
        type = "enum",
        order = 2,
        choices = containers,
        optional = true,
      },
      extra_params = {
        type = "string",
        desc = "Add extra parameter(s) for the docker command",
        optional = true,
        order = 3,
      },
    }
  end,
  builder = function(params)
    local args = {}

    if params.cmd then
      local container = false
      for _, v in ipairs(params.cmd) do
        table.insert(args, v)
        if container or vim.tbl_contains(cmds, v) then
          container = true
        end
      end

      if container and params.container then
        table.insert(args, params.container)
      end
    end

    if params.extra_params then
      -- Simple split by space, might need more robust parsing for quoted args
      for _, part in ipairs(vim.split(params.extra_params, " ", { trimempty = true })) do
        table.insert(args, part)
      end
    end

    ---@type overseer.TaskDefinition
    local task_def = {
      cmd = { "docker" },
      args = args,
      components = {
        "dispatch", -- Use dispatch component like in docker-compose
      },
    }

    return task_def
  end,
}
