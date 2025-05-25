local files = require("overseer.files")
local overseer = require("overseer")

---@type overseer.TemplateFileDefinition
local tmpl = {
  cache_key = function(opts)
    return opts.dir
  end,
  params = {
    args = { type = "list", delimiter = " " },
    cwd = { optional = true },
  },
  builder = function(params)
    local args = params.args or {}
    return {
      cmd = "pdm",
      args = args,
      cwd = params.cwd,
      components = {
        -- { "on_output_quickfix", set_diagnostics = true },
        -- "on_result_diagnostics",
        -- https://github.com/stevearc/overseer.nvim/blob/master/doc/components.md#open_output
        {
          "open_output",
          on_start = "if_no_on_output_quickfix",
          on_complete = "failure",
        },
        -- https://github.com/stevearc/overseer.nvim/blob/master/doc/components.md#unique
        {
          "unique",
        },
        "default",
      },
    }
  end,
}

---@type overseer.TemplateProvider
return {
  name = "PDM",
  priority = 60,
  condition = {
    callback = function()
      return vim.fn.executable("pdm") == 1
    end,
  },
  generator = function(opts, cb)
    local ret = {
      overseer.wrap_template(tmpl, {
        name = "(PDM) install ",
        condition = {
          callback = function(opts)
            return files.exists(
              files.join(opts.dir, "pdm.lock")
                or files.exists(files.join(opts.dir, "pyproject.toml"))
            )
          end,
        },
      }, {
        args = {
          "install",
          "-p",
          opts.dir,
        },
      }),
    }
    for _, filename in ipairs({ "requirements.txt", "setup.py" }) do
      table.insert(
        ret,
        overseer.wrap_template(tmpl, {
          name = "(PDM) import " .. filename,
          condition = {
            callback = function(opts)
              return files.exists(files.join(opts.dir, filename))
                and not files.exists(files.join(opts.dir, "/pyproject.toml"))
            end,
          },
        }, {
          args = {
            "import",
            filename,
          },
        })
      )
    end

    cb(ret)
  end,
}
