local files = require("overseer.files")

---@type overseer.TemplateProvider
return {
  name = "Run Shell Script",
  generator = function(opts, cb)
    local scripts = vim.tbl_filter(function(filename)
      return filename:match("%.sh$")
    end, files.list_files(opts.dir))
    local ret = {}
    for _, filename in ipairs(scripts) do
      table.insert(ret, {
        name = filename,
        params = {
          args = { optional = true, type = "list", delimiter = " " },
        },
        builder = function(params)
          return {
            cmd = { vim.fs.joinpath(opts.dir, filename) },
            args = params.args,
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
