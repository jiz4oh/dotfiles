return {
  generator = function(opts)
    if
      vim.b.dispatch == nil
      or vim.startswith(vim.b.dispatch, ":")
      or vim.startswith(vim.b.dispatch, "!")
    then
      return "b:dispatch not set, or starts with : or !"
    end

    local cmd, opts = unpack(vim.fn["personal#functions#parse_start"](vim.b.dispatch))
    if cmd == vim.NIL then
      return "Could not parse start of b:dispatch"
    end
    local tmpl = {
      name = "dispatch",
      builder = function()
        return {
          cmd = vim.fn["dispatch#expand"](cmd),
          cwd = opts.dir,
          name = opts.title,
          components = {
            { "on_output_quickfix", set_diagnostics = true },
            {
              "open_output",
              on_start = "if_no_on_output_quickfix",
              on_complete = "failure",
            },
            "on_result_diagnostics",
            "default",
          },
        }
      end,
    }

    return { tmpl }
  end,
}
