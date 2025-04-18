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
        params = {
          task = {
            desc = "Action",
            type = "string",
            -- type = "enum",
            -- choices = {
            --   "build",
            --   "create",
            --   "down",
            --   "images",
            --   "kill",
            --   "pause",
            --   "ps",
            --   "pull",
            --   "rm",
            --   "start",
            --   "stop",
            --   "top",
            --   "unpause",
            --   "up",
            -- },
            order = 1,
          },
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
          extra_params = {
            type = "string",
            desc = "Add extra parameter(s)",
            optional = true,
            order = 4,
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

          if params.task then
            table.insert(args, params.task)
          end

          if params.detached and (params.task == "up" or params.task == "start") then
            table.insert(args, "-d")
          end

          if params.extra_params then
            table.insert(args, params.extra_params)
          end

          ---@type overseer.TaskDefinition
          local task_def = {
            cmd = "docker",
            args = args,
            components = {
              "dispatch"
            },
          }

          return task_def
        end,
      },
    }

    cb(ret)
  end,
}
