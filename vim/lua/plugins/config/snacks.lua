local lsp_handlers = {
  ["textDocument/documentSymbol"] = function(err, result, ctx, config)
    Snacks.picker.lsp_symbols()
  end,
  ["workspace/symbol"] = function(err, result, ctx, config)
    Snacks.picker.lsp_workspace_symbols()
  end,
}

_G.fix_padding = function()
  vim.g._fix_padding = true
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  if not normal.bg then
    return
  end
  io.write(string.format("\027]11;#%06x\027\\", normal.bg))
end

_G.revert_fix_padding = function()
  vim.g._fix_padding = false
  io.write("\027]111\027\\")
end

-- fix padding on terminal
vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
  callback = fix_padding,
})

vim.api.nvim_create_autocmd("UILeave", {
  callback = revert_fix_padding,
})

---@type LazyPluginSpec
return {
  "folke/snacks.nvim",
  optional = true,
  priority = 1000,
  lazy = false,
  keys = {
    {
      "]]",
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = "Next Reference",
      mode = { "n" },
    },
    {
      "[[",
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = "Prev Reference",
      mode = { "n" },
    },
    {
      "<leader>sf",
      function()
        Snacks.picker.recent()
      end,
      desc = "Search recent files",
      mode = { "n" },
    },
    {
      "<leader>sP",
      function()
        Snacks.picker()
      end,
      desc = "Open Snacks Pickers",
      mode = { "n" },
    },
    {
      "<leader>sd",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "Open Diagnostics Picker",
      mode = { "n" },
    },
    {
      "<leader>sD",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "Open Diagnostics Picker",
      mode = { "n" },
    },
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
    {
      "<leader>ld",
      function()
        Snacks.picker.lsp_definitions({ unique_lines = true })
      end,
    },
    {
      "<leader>lD",
      function()
        Snacks.picker.lsp_declarations({ unique_lines = true })
      end,
    },
    {
      "<leader>li",
      function()
        Snacks.picker.lsp_implementations({ unique_lines = true })
      end,
    },
    {
      "<leader>lr",
      function()
        Snacks.picker.lsp_references({ unique_lines = true, include_declaration = false })
      end,
    },
    {
      "<leader>lt",
      function()
        Snacks.picker.lsp_type_definitions({ unique_lines = true })
      end,
    },
  },
  cmd = {
    "Notification",
  },
  ---@type snacks.plugins.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = {
      enabled = true,
      setup = function(ctx)
        if vim.fn.exists(":NoMatchParen") ~= 0 then
          vim.cmd([[NoMatchParen]])
        end
        Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
        vim.b.minianimate_disable = true
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then
            vim.bo[ctx.buf].syntax = ctx.ft
          end
        end)

        -- too long line with wrap freezes neovim
        -- e.g. https://raw.githubusercontent.com/BingyanStudio/LapisCV/refs/heads/main/templates/obsidian/.obsidian/snippets/fonts.css
        vim.wo.wrap = false
        -- https://github.com/jdhao/nvim-config/blob/30b3c09dda1e84f6df254796d3b058e9e0b207d8/lua/custom-autocmd.lua#L230-L241
        --  turning off relative number helps a lot
        vim.wo.relativenumber = false
        vim.wo.number = false

        vim.bo.swapfile = false
        vim.bo.bufhidden = "unload"
        vim.bo.undolevels = -1
      end,
    },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    quickfile = {
      enabled = true,
      exclude = { "latex" },
    },
    notifier = { enabled = true },
    input = {
      enabled = true,
      win = {
        relative = "cursor",
        row = 1
      }
    },
    indent = { enabled = true },
    image = { enabled = true },
    picker = {
      ui_select = true,
      layout = {
        layout = {
          backdrop = false,
          width = 0.9,
          min_width = 80,
          height = 0.8,
          min_height = 30,
          box = "vertical",
          border = "rounded",
          title = "{title} {live} {flags}",
          title_pos = "center",
          { win = "input", height = 1, border = "bottom" },
          { win = "list", border = "none" },
          { win = "preview", title = "{preview}", height = 0.6, border = "top" },
        },
      },
      win = {
        -- input window
        input = {
          keys = {
            -- to close the picker on ESC instead of going to normal mode,
            -- add the following keymap to your config
            ["/"] = "toggle_focus",
          },
        },
      },
      sources = {
        projects = {
          patterns = vim.g.project_markers,
        },
        plugin = {
          finder = "plugin",
          format = "text",
          preview = "preview",
          confirm = "copy",
          formatters = {
            file = { filename_only = true },
          },
        },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        if Snacks == nil then
          return
        end

        vim.api.nvim_create_autocmd("User", {
          pattern = "OilActionsPost",
          callback = function(event)
              if event.data.actions.type == "move" then
                  Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
              end
          end,
        })

        -- enable numbers since has bigfile plugin
        vim.o.number = true

        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command
        vim.api.nvim_create_user_command("Notification", function()
          Snacks.picker.notifications()
        end, { desc = "Notification History" })

        vim.api.nvim_create_user_command("Maps", function()
          Snacks.picker.keymaps({
            modes = { "n" },
          })
        end, { desc = "Normal Keymaps Definitions" })

        vim.api.nvim_create_user_command("Imaps", function()
          Snacks.picker.keymaps({
            modes = { "i" },
          })
        end, { desc = "Insert Keymaps Definitions" })

        vim.api.nvim_create_user_command("Xmaps", function()
          Snacks.picker.keymaps({
            modes = { "v", "x" },
          })
        end, { desc = "Virtual Keymaps Definitions" })

        vim.api.nvim_create_user_command("Omaps", function()
          Snacks.picker.keymaps({
            modes = { "o" },
          })
        end, { desc = "Operator Keymaps Definitions" })

        vim.api.nvim_create_user_command("Commands", function()
          Snacks.picker.commands()
        end, { desc = "Commands Definitions" })

        vim.api.nvim_create_user_command("History", function(opts)
          if opts.fargs[1] == ":" then
            Snacks.picker.command_history()
          elseif opts.fargs[1] == "/" then
            Snacks.picker.search_history()
          else
            Snacks.picker.recent()
          end
        end, {
          desc = "History",
          nargs = "*", -- 接受任意参数
        })
        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle
          .option("background", { off = "light", on = "dark", name = "Dark Background" })
          :map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.new({
          id = "padding",
          name = "Padding",
          get = function()
            return vim.g._fix_padding
          end,
          set = function(state)
            if state then
              fix_padding()
            else
              revert_fix_padding()
            end
          end,
        }):map("<leader>up")

        for _, m in ipairs(vim.tbl_keys(lsp_handlers)) do
          vim.lsp.handlers[m] = lsp_handlers[m]
        end
      end,
    })
  end,
}
