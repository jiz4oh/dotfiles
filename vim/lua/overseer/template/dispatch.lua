---@type overseer.TemplateDefinition
return {
  name = "dispatch",
  builder = function()
    local cmd, opts = unpack(vim.fn["personal#functions#parse_start"](vim.b.dispatch))
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
  condition = {
    callback = function(task)
      return vim.fn["dispatch#expand"]
        and vim.b.dispatch ~= nil
        and not vim.startswith(vim.b.dispatch, ":")
        and not vim.startswith(vim.b.dispatch, "!")
    end,
  },
}
