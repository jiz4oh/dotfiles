local files = require("overseer.files")
local TAG = require("overseer.constants").TAG

local pattern = vim.regex([[^\(docker-\)\?compose\(\.[a-zA-Z0-9_-]\+\)*\.ya\?ml$]]) -- Equivalent without very magic

---@type overseer.TemplateProvider
return {
  name = "docker-compose",
  condition = {
    callback = function(opts)
      local all_files = files.list_files(vim.loop.cwd())
      local filtered = vim.tbl_filter(function(filename)
        local matched = pattern:match_str(filename)
        return matched ~= nil
      end, all_files)
      return not vim.tbl_isempty(filtered)
    end,
  },
  generator = function(opts, cb)
    local all_files = files.list_files(vim.loop.cwd())
    local filtered = vim.tbl_filter(function(filename)
      local matched = pattern:match_str(filename)
      return matched ~= nil
    end, all_files)

    local default = filtered[1]
    local ret = {
      {
        -- Add a space for better readability
        name = "docker compose logs -f",
        priority = 39,
        tags = { TAG.RUN },
        params = {
          file = {
            type = "string",
            desc = "Name of docker-compose file. Empty means " .. default,
            subtype = {
              type = "enum",
              choices = filtered,
            },
            default = default,
            optional = true,
            order = 3,
          },
        },
        builder = function(params)
          local args = { "compose" }

          table.insert(args, "-f")
          if params.file then
            table.insert(args, params.file)
          else
            table.insert(args, default)
          end

          table.insert(args, "logs")
          table.insert(args, "-f")

          ---@type overseer.TaskDefinition
          return {
            cmd = "docker",
            args = args,
            strategy = "terminal",
            components = {
              "start",
            },
          }
        end,
      },
      {
        -- Add a space for better readability
        name = "docker compose force restart",
        priority = 39,
        tags = { TAG.RUN },
        params = {
          detached = {
            type = "boolean",
            desc = "Run as detached?",
            default = true,
            order = 2,
          },
          file = {
            type = "string",
            desc = "Name of docker-compose file. Empty means " .. default,
            subtype = {
              type = "enum",
              choices = f,
            },
            default = default,
            optional = true,
            order = 3,
          },
        },
        builder = function(params)
          local args = { "compose" }

          table.insert(args, "-f")
          if params.file then
            table.insert(args, params.file)
          else
            table.insert(args, default)
          end

          table.insert(args, "down")
          table.insert(args, "&&")
          table.insert(args, "docker")
          table.insert(args, "compose")
          table.insert(args, "up")

          if params.detached then
            table.insert(args, "-d")
          end

          ---@type overseer.TaskDefinition
          return {
            cmd = "docker",
            args = args,
            components = {
              "start",
            },
          }
        end,
      },
      {
        -- Add a space for better readability
        name = "docker compose ",
        priority = 40,
        params = function() -- https://github.com/stevearc/overseer.nvim/issues/86
          local stdout = vim.system({ "docker", "compose", "ls", "--format", "json" }):wait().stdout
          local projects = {}
          for _, v in ipairs(vim.json.decode(stdout)) do
            table.insert(projects, v.Name)
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
              choices = {
                "compose.yaml",
                "compose.yml",
                "docker-compose.yaml",
                "docker-compose.yml",
              },
              optional = true,
              order = 4,
            },
            detached = {
              type = "boolean",
              desc = "Run as detached?",
              default = true,
              order = 5,
            },
            cwd = { optional = true },
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

          if params.detached and (params.cmd == "up" or params.cmd == "start") then
            table.insert(args, "-d")
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
      },
    }

    cb(ret)
  end,
}
