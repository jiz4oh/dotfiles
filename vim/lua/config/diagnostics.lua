local function get_diagnostics()
  local line = vim.fn.line(".") - 1
  local diagnostics = vim.diagnostic.get(0, { lnum = line })
  if #diagnostics > 0 then
    return table.concat(
      vim.tbl_map(function(d)
        return d.message
      end, diagnostics),
      " "
    )
  end
end

if vim.fn.has("nvim-0.6") ~= 1 then
  return
end

local diagnostics_fmt = {
  [vim.diagnostic.severity.ERROR] = "E",
  [vim.diagnostic.severity.WARN] = "W",
  [vim.diagnostic.severity.INFO] = "I",
  [vim.diagnostic.severity.HINT] = "D",
}

_G.my_diagnostic_format_func = function(diagnostic)
  return string.format(
    "[%s] [%s] %s",
    diagnostics_fmt[diagnostic.severity],
    diagnostic.source,
    diagnostic.message
  )
end

vim.diagnostic.config({
  underline = false,
  float = {
    severity_sort = true,
    source = true,
  },
  virtual_text = {
    current_line = true,
    severity_sort = true,
    source = true,
    format = my_diagnostic_format_func,
  },
  virtual_lines = false,
})

vim.keymap.set("n", "yd", function()
  local diagnostics = get_diagnostics()
  if diagnostics ~= nil then
    vim.fn.setreg("+", diagnostics) -- Set register for non-SSH or if OSC52 fails
    if vim.fn.has("nvim-0.10") == 1 and vim.fn.exists("$SSH_TTY") == 1 then
      -- Explicitly use OSC52 when in SSH, similar to the TextYankPost handler
      require("vim.ui.clipboard.osc52").copy("+")({ diagnostics })
    end
    vim.notify("Diagnostic copied to clipboard", vim.log.levels.INFO)
  else
    vim.notify("No diagnostics on current line", vim.log.levels.WARN)
  end
end)
