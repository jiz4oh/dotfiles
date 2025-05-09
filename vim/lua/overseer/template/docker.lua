local files = require("overseer.files")

---@type overseer.TemplateProvider
return {
  name = "docker ",
  priority = 60,
  params = {
    task = {
      desc = "Docker command (e.g., build, run, ps, images)",
      type = "string",
      default = "ps",
      order = 1,
    },
    extra_params = {
      type = "string",
      desc = "Add extra parameter(s) for the docker command",
      optional = true,
      order = 2,
    },
  },
  builder = function(params)
    local args = {}

    if params.task then
      table.insert(args, params.task)
    end

    if params.extra_params then
      -- Simple split by space, might need more robust parsing for quoted args
      for _, part in ipairs(vim.split(params.extra_params, " ", { trimempty = true })) do
        table.insert(args, part)
      end
    end

    ---@type overseer.TaskDefinition
    local task_def = {
      cmd = "docker",
      args = args,
      components = {
        "dispatch", -- Use dispatch component like in docker-compose
      },
    }

    return task_def
  end,
}
