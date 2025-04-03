local function format_name(cmd)
  return string.format("(rails) %s", cmd)
end

---@type overseer.TemplateFileProvider
return {
  cache_key = function(opts)
    return vim.fn.getcwd()
  end,
  condition = {
    callback = function(opts)
      if vim.fn.executable("rails") == 0 then
        return false, 'Command "rake" not found'
      end
      if not vim.fn["rails#complete_rails"] then
        return false, "No Vim-Rails"
      end
      return true
    end,
  },
  generator = function(opts, cb)
    ---@type overseer.TemplateDefinition[]
    local ret = {
      {
        name = format_name("new"),
        priority = 100,
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
        priority = 60,
        builder = function()
          return {
            cmd = { "rails", command },
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
              priority = 60,
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
