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
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
    {
      "<leader><Tab>",
      function()
        Snacks.dashboard()
      end,
      desc = "Open Dashboard",
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
    dashboard = {
      enabled = true,
      preset = {
        pick = "fzf-lua",
      },
      formats = {
        key = function(item)
          return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
        end,
      },
      sections = {
        { section = "header" },
        { title = "Bookmarks", padding = 1 },
        function()
          local picker = require("config.picker")
          local defaults, user = picker.bookmark_data()
          local items = {}
          

          for _, path in ipairs(defaults) do
            table.insert(items, {
              icon = " ",
              file = path,
              action = function()
                picker.open_bookmark(path)
              end,
              autokey = true,
            })
          end
          for _, path in ipairs(user) do
            table.insert(items, {
              icon = " ",
              file = path,
              action = function()
                picker.open_bookmark(path)
              end,
              autokey = true,
            })
          end

          return items
        end,
        { title = "Sessions", padding = 1 },
        { section = "projects", padding = 1 },
        { title = "MRU", padding = 1 },
        { section = "recent_files", limit = 8, padding = 1 },
        { section = "startup" },
      },
    },
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
        row = 1,
      },
    },
    indent = { enabled = true },
    image = { enabled = true },
    picker = {
      pick = {
        picker = "snacks", ---@type snacks.profiler.Picker
        ---@type snacks.profiler.Badge.type[]
        badges = { "time", "count", "name" },
        ---@type snacks.profiler.Highlights
        preview = {
          badges = { "time", "pct", "count" },
          align = "right",
        },
      },
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
        Snacks.toggle
          .new({
            id = "padding",
            name = "Transparent Padding",
            get = function()
              return vim.g._transparent == true
            end,
            set = function(state)
              if state then
                ui.make_transparent(true)
              else
                ui.make_transparent(false)
              end
            end,
          })
          :map("<leader>up")
      end,
    })
  end,
}
