local files = require("overseer.files")
local overseer = require("overseer")

---@type overseer.TemplateProvider
return {
  name = "PDM",
  generator = function(opts, cb)
    if vim.fn.executable("pdm") ~= 1 then
      return {}
    end

    local ret = {}

    if
      files.any_exists(
        vim.fs.joinpath(opts.dir, "pyproject.toml"),
        vim.fs.joinpath(opts.dir, "pdm.lock")
      )
    then
      table.insert(ret, {
        name = "(PDM) install ",
        builder = function(params)
          local args = params.args or {}
          return {
            cmd = "pdm",
            args = {
              "install",
              "-p",
              opts.dir,
            },
            cwd = opts.dir,
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

    if not files.exists(vim.fs.joinpath(opts.dir, "/pyproject.toml")) then
      for _, filename in ipairs({ "requirements.txt", "setup.py" }) do
        if files.exists(vim.fs.joinpath(opts.dir, filename)) then
          table.insert(ret, {
            name = "(PDM) import " .. filename,
            condition = {
              callback = function(opts) end,
            },
            builder = function(params)
              local args = params.args or {}
              return {
                cmd = "pdm",
                args = {
                  "import",
                  filename,
                },
                cwd = opts.dir,
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
      end
    end

    cb(ret)
  end,
}
