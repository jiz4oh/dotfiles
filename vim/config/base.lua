vim.g.ale_disable_lsp = 1

-- conflict with fzf
-- if vim.fn.has("nvim-0.11") == 1 then
--   vim.o.winborder = "rounded"
-- end

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

-- :help vim.lsp.ListOpts
-- https://github.com/neovim/neovim/issues/32384
-- vim.lsp.on_list = function(options)
--   if options.items == nil or #options.items == 0 then
--     vim.notify("No items")
--     return
--   end
--
--   local bufnr = options.context.bufnr
--   local items = options.items
--   vim.ui.select(items, {
--     prompt = options.title,
--     format_item = function(v)
--       local bufname = vim.fn.bufname(bufnr) or v.filename
--       return bufname .. ":" .. v.lnum .. ":" .. v.col .. " " .. v.text
--     end,
--   }, function(item, _)
--     if item == nil then
--       return
--     end
--
--     vim.cmd("normal! m'")
--     vim.cmd("edit " .. item.filename)
--     vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
--     vim.cmd("normal! zzzv")
--   end)
-- end

if vim.fn.has("nvim-0.8") == 1 then
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client == nil then
        return
      end

      if vim.fn.has("nvim-0.10") == 1 then
        if
          client.supports_method("textDocument/inlayHints")
          and client.server_capabilities.inlayHintProvider
        then
          vim.lsp.inlay_hint.enable()
        end
      end

      if
        client.supports_method("textDocument/hover")
        and client.server_capabilities.hoverProvider
      then
        -- no K mapping here, so keywordprg can be overrode by others like scriptease.vim
        vim.o.keywordprg = "v:lua.vim.lsp.buf.hover({'border': 'rounded')"
      end

      if
        client.supports_method("textDocument/definition")
        and client.server_capabilities.definitionProvider
      then
        vim.keymap.set({ "n" }, "gd", function()
          vim.lsp.buf.definition({ on_list = vim.lsp.on_list })
        end, { buffer = true })
      end

      if
        client.supports_method("textDocument/declaration")
        and client.server_capabilities.declarationProvider
      then
        vim.keymap.set({ "n" }, "gD", function()
          vim.lsp.buf.declaration({ on_list = vim.lsp.on_list })
        end, { buffer = true })
      end

      vim.g["vista_" .. vim.api.nvim_get_option_value("filetype", { buf = bufnr }) .. "_executive"] =
        "nvim_lsp"

      -- remove ruff from ale_linters since it report to nvim directly
      local ale_linters_ignore = vim.b.ale_linters_ignore or {}
      table.insert(ale_linters_ignore, "ruff")
      vim.b.ale_linters_ignore = ale_linters_ignore

      vim.notify_once("LSP " .. client.name .. " attached")
    end,
  })
end

if vim.fn.has("nvim-0.7") == 1 then
  vim.keymap.set({ "n" }, "<leader>ld", function()
    vim.lsp.buf.definition({ on_list = vim.lsp.on_list })
  end)
  vim.keymap.set({ "n" }, "<leader>lD", function()
    vim.lsp.buf.declaration({ on_list = vim.lsp.on_list })
  end)
  vim.keymap.set({ "n" }, "<leader>lt", function()
    vim.lsp.buf.type_definition({ on_list = vim.lsp.on_list })
  end)
  vim.keymap.set({ "n" }, "<leader>li", function()
    vim.lsp.buf.implementation({ on_list = vim.lsp.on_list })
  end)
  vim.keymap.set({ "n" }, "<leader>lr", function()
    vim.lsp.buf.references({ includeDeclaration = false }, { on_list = vim.lsp.on_list })
  end)
  vim.keymap.set({ "n" }, "<leader>lR", function()
    vim.lsp.buf.rename()
  end)
  vim.keymap.set({ "n" }, "<leader>ls", function()
    vim.lsp.buf.document_symbol({ on_list = vim.lsp.on_list })
  end)
  vim.keymap.set({ "n" }, "<leader>lS", function()
    vim.lsp.buf.workspace_symbol(nil, { on_list = vim.lsp.on_list })
  end)
  vim.keymap.set({ "n" }, "<leader>lK", function()
    vim.lsp.buf.hover({ border = "rounded" })
  end)

  vim.keymap.set({ "n", "v" }, "<leader>la", function()
    vim.lsp.buf.code_action()
  end)
  vim.keymap.set({ "n", "v" }, "<leader>lf", function()
    vim.lsp.buf.format()
  end)
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
end

if vim.fn.has("nvim-0.11") == 1 then
  vim.keymap.del({ "n" }, "grn")
  vim.keymap.del({ "n", "x" }, "gra")
  vim.keymap.del({ "n" }, "gri")
end
