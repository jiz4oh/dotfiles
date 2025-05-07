local files = require("overseer.files")
local TAG = require("overseer.constants").TAG

local function format_name(cmd)
  return string.format("(launchctl) %s", cmd)
end

---@type overseer.TemplateFileProvider
return {
  name = "Run Launchctl",
  priority = 70,
  generator = function(opts, cb)
    local f = vim.tbl_filter(function(filename)
      return filename:match("%.plist$")
    end, files.list_files(opts.dir))
    local ret = {}

    local sudo = not opts.dir:match("^/Users")
    for _, filename in ipairs(f) do
      table.insert(ret, {
        name = format_name("Reload " .. filename),
        builder = function(params)
          local path = files.join(opts.dir, filename)
          ---@type overseer.TaskDefinition
          local spec = {
            components = {
              "default",
            },
          }

          if sudo then
            spec.cmd = "sudo"
            spec.args = {
              "-A",
              "sh",
              "-c",
              "'launchctl unload " .. path .. " && launchctl load " .. path .. "'",
            }
          else
            spec.cmd = "sh"
            spec.args = {
              "-c",
              "'launchctl unload " .. path .. " && launchctl load " .. path .. "'",
            }
          end
          return spec
        end,
      })
    end

    cb(ret)
  end,
}
