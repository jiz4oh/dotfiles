local TAG = require("overseer.constants").TAG

local function format_name(cmd)
  return string.format("(rails) %s", cmd)
end

---@type overseer.TemplateFileProvider
return {
  cache_key = function(opts)
    return vim.fn.getcwd()
  end,
  generator = function(opts, cb)
    if vim.fn.executable("rails") == 0 then
      return {}
    end

    if vim.g.loaded_rails ~= 1 then
      return {}
    end

    if vim.fn["RailsDetect"](opts.dir) ~= 1 then
      local ret = {
        {
          name = format_name("new"),
          params = {
            name = {
              name = "app_name",
              desc = "Name of the new Rails application",
              optional = false,
            },
          },
          builder = function(params)
            return {
              cmd = { "rails", "new", params.name },
            }
          end,
        },
      }
      return cb(ret)
    end

    ---@type overseer.TemplateDefinition[]
    local ret = {
      {
        name = format_name("runner"),
        priority = 100,
        params = {
          code = {
            name = "code",
            desc = "Code to run in the Rails environment",
            optional = false,
          },
        },
        builder = function(params)
          return {
            cmd = { "rails", "runner", params.code },
          }
        end,
      },
    }

    for _, command in ipairs({ "server", "console", "dbconsole" }) do
      table.insert(ret, {
        name = format_name(command),
        tags = { TAG.RUN },
        builder = function()
          return {
            cmd = { "rails", command },
            strategy = "terminal",
            components = {
              {
                "open_output",
                on_start = "always",
                on_complete = "failure",
                direction = "float",
                focus = true,
              },
              "on_exit_set_status",
            },
          }
        end,
      })
    end

    vim.schedule(function()
      for _, command in ipairs({ "generate", "destroy" }) do
        for _, line in ipairs(vim.fn["rails#complete_rails"]("", "Rails " .. command .. " ", 0)) do
          if line ~= "new" then
            table.insert(ret, {
              name = format_name(command .. " " .. line),
              builder = function()
                return {
                  cmd = { "rails", command, line },
                }
              end,
            })
          end
        end
      end

      cb(ret)
    end)
  end,
}
