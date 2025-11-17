local files = require("overseer.files")

---@type overseer.TemplateProvider
return {
  name = "PDM",
  condition = {
    callback = function()
      return vim.fn.executable("pdm") == 1
    end,
  },
  generator = function(opts, cb)
    if vim.fn.executable("pdm") ~= 1 then
      return {}
    end
    local ret = {
vim.fs.joinpath(opts.dir, "pyproject.toml"))
            )
          end,
        },
        builder = function()
          return {
            cmd = "pdm",
            args = {
              "install",
              "-p",
              opts.dir,
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
vim.fs.joinpath(opts.dir, filename)
vim.fs.joinpath(opts.dir, filename))
              and not files.exists(vim.fs.joinpath(opts.dir, "/pyproject.toml"))
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
