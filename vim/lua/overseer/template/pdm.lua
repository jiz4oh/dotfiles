local files = require("overseer.files")

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
      {
        name = "(PDM) install ",
        cache_key = function(opts)
          return opts.dir
        end,
        condition = {
          callback = function(opts)
            return files.exists(files.join(opts.dir, "pdm.lock") or files.exists(files.join(opts.dir, "pyproject.toml")))
          end,
        },
        builder = function()
          return {
            cmd = "pdm",
            args = {
              "install",
              "-p",
              opts.dir
            },
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
      },
    }
    for _, filename in ipairs({ "requirements.txt", "setup.py" }) do
      table.insert(ret, {
        name = "(PDM) import " .. filename,
        cache_key = function(opts)
          return files.join(opts.dir, filename)
        end,
        condition = {
          callback = function(opts)
            return files.exists(files.join(opts.dir, filename))
              and not files.exists(files.join(opts.dir, "/pyproject.toml"))
          end,
        },
        builder = function()
          return {
            cmd = "pdm",
            args = {
              "import",
              filename,
            },
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
      })
    end

    cb(ret)
  end,
}
