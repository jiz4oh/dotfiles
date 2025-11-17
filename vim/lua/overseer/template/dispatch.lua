local parse_cmd = function()
  return unpack(vim.fn["personal#functions#parse_start"](vim.b.dispatch))
end

---@type overseer.TemplateProvider
return {
  name = "dispatch",
  generator = function(opts, cb)
    if vim.g.loaded_dispatch ~= 1 then
      return {}
    end

    local cmd, opts = parse_cmd()
    if cmd == vim.NIL then
      return {}
    end
    local ret = {
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

    cb(ret)
  end,
}
