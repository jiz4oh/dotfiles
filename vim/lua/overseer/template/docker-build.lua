local files = require("overseer.files")
local TAG = require("overseer.constants").TAG

---@type overseer.TemplateDefinition
return {
  name = "docker build",
  priority = 30,
  tags = { TAG.BUILD },
  condition = {
    callback = function(task)
      local filtered = vim.tbl_filter(function(filename)
        return filename:match("Dockerfile")
      end, files.list_files(vim.loop.cwd()))
      return not vim.tbl_isempty(filtered)
    end,
  },
  params = {
    tag = {
      type = "string",
      desc = 'Name and optionally a tag (format: "name:tag")',
      default = "",
    },
    extra_params = {
      type = "string",
      desc = "Add extra parameter(s)",
      optional = true,
    },
  },
  builder = function(params)
    local file = vim.fn.expand("%")
    local args = { "build" }

    if params.tag and params.tag ~= "" then
      table.insert(args, "-t")
      table.insert(args, params.tag)
    end

    if params.extra_params then
      table.insert(args, params.extra_params)
    end

    table.insert(args, vim.loop.cwd())
    return {
      cmd = { "docker" },
      args = args,
    }
  end,
}
