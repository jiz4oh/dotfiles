if vim.fn["floaterm#buflist#add"] ~= nil then
  local toggle = "<c-\\><c-n><cmd>call FloatermHide(bufnr())<cr>"
else
  local toggle = "<c-\\><c-n><Plug>(REPLHideOrFocus)"
end

---@type LazyPluginSpec
return {
  "milanglacier/yarepl.nvim",
  optional = true,
  event = "VeryLazy",
  keys = {
    { "gzr", "<Plug>(REPLStart)", noremap = false, mode = "n", desc = "Start an REPL" },
    {
      vim.g.floaterm_keymap_toggle or "<m-=>",
      toggle,
      ft = "REPL",
      noremap = false,
      mode = { "t", "n" },
      desc = "Hide Current REPL",
    },
    {
      "gz",
      "<Plug>(REPLSendVisual)",
      noremap = false,
      mode = "v",
      desc = "Source visual region to REPL",
    },
    {
      "gz",
      "<Plug>(REPLSendOperator)",
      noremap = false,
      mode = "n",
      desc = "Send operator to REPL",
    },
    { "gzz", "<Plug>(REPLSendLine)", noremap = false, mode = "n", desc = "Send line to REPL" },
  },
  opts = {
    wincmd = function(bufnr, name)
      if vim.fn["floaterm#buflist#add"] ~= nil then
        vim.fn["floaterm#buflist#add"](bufnr)
        vim.fn["floaterm#terminal#open"](bufnr, "", {}, {
          name = name,
          title = title,
          position = "topright",
          width = 0.4,
          height = 0.999999,
        })
        vim.api.nvim_create_autocmd("BufHidden", {
          buffer = bufnr,
          callback = function()
            vim.fn["FloatermHide"](bufnr)
          end,
        })
      else
        vim.api.nvim_open_win(bufnr, true, {
          relative = "editor",
          row = math.floor(vim.o.lines * 0.25),
          col = math.floor(vim.o.columns * 0.25),
          width = math.floor(vim.o.columns * 0.5),
          height = math.floor(vim.o.lines * 0.5),
          style = "minimal",
          title = name,
          border = "rounded",
          title_pos = "center",
        })
      end
    end,
    metas = {
      aider = {
        cmd = "aider --no-pretty --no-auto-commits",
        formatter = "bracketed_pasting_no_final_new_line",
        source_syntax = "aichat",
      },
      aichat = false,
    },
  },
}
