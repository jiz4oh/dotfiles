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

-- https://github.com/neovim/neovim/pull/25872
-- https://github.com/neovim/neovim/pull/26064
-- :h clipboard-osc52
if vim.fn.has("nvim-0.10") == 1 then
  vim.keymap.set({ "n", "v", "o" }, "<leader>y", '"+y', { noremap = true })
  vim.keymap.set({ "n", "v", "o" }, "<leader>Y", '"+Y', { remap = true })

  if vim.fn.exists("$SSH_TTY") == 1 then
    vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
        local regs = { "", "+", "*" }
        if vim.v.event.operator == "y" and vim.tbl_contains(regs, vim.v.event.regname) then
          local copy_to_unnamedplus = require("vim.ui.clipboard.osc52").copy("+")
          copy_to_unnamedplus(vim.v.event.regcontents)
          local copy_to_unnamed = require("vim.ui.clipboard.osc52").copy("*")
          copy_to_unnamed(vim.v.event.regcontents)
        end
      end,
    })

    vim.keymap.set("n", "<leader>yd", function()
      local diagnostics = get_diagnostics()
      if diagnostics ~= nil then
        require("vim.ui.clipboard.osc52").copy("+")({ diagnostics })
        vim.notify("Diagnostic copied to clipboard", vim.log.levels.INFO)
      else
        vim.notify("No diagnostics on current line", vim.log.levels.WARN)
      end
    end)
  end
end

if vim.fn.has("nvim-0.6") == 1 then
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

  vim.diagnostic.config({ float = { severity_sort = true, source = true } })
  vim.diagnostic.config({
    virtual_text = { severity_sort = true, source = true, format = my_diagnostic_format_func },
  })

  vim.keymap.set("n", "yd", function()
    local diagnostics = get_diagnostics()
    if diagnostics ~= nil then
      vim.fn.setreg("+", diagnostics)
      vim.notify("Diagnostic copied to clipboard", vim.log.levels.INFO)
    else
      vim.notify("No diagnostics on current line", vim.log.levels.WARN)
    end
  end)
end
