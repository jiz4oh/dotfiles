local ui = require("config.ui")

local dashboard_pane_width = 60
local dashboard_pane_gap = 0
local dashboard_header_width = dashboard_pane_width * 2 + dashboard_pane_gap
local dashboard_header =
  [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]

local function split_dashboard_header()
  local left, right = {}, {}

  for _, line in ipairs(vim.split(dashboard_header, "\n", { plain = true })) do
    local expanded = {}
    for _, char in ipairs(vim.fn.split(line, [[\zs]])) do
      expanded[#expanded + 1] = char:rep(2)
    end

    local value = table.concat(expanded)
    local padding = math.floor((dashboard_header_width - vim.fn.strdisplaywidth(value)) / 2)
    value = (" "):rep(padding) .. value
    value = value .. (" "):rep(dashboard_header_width - vim.fn.strdisplaywidth(value))

    left[#left + 1] = vim.fn.strcharpart(value, 0, dashboard_pane_width)
    right[#right + 1] = vim.fn.strcharpart(value, dashboard_pane_width, dashboard_pane_width)
  end

  return left, right
end

local dashboard_header_left, dashboard_header_right = split_dashboard_header()

local function dashboard_header_text(lines)
  return { { table.concat(lines, "\n"), hl = "header" } }
end

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
      width = dashboard_pane_width,
      pane_gap = dashboard_pane_gap,
      preset = {
        header = dashboard_header,
        pick = "fzf-lua",
        keys = {
          {
            icon = " ",
            key = "f",
            desc = "Find File",
            action = ":lua require('config.picker').files()",
          },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          {
            icon = " ",
            key = "g",
            desc = "Find Text",
            action = ":lua require('config.picker').rg()",
          },
          {
            icon = " ",
            key = "r",
            desc = "Recent Files",
            action = ":lua require('config.picker').recent()",
          },
          {
            icon = " ",
            key = "b",
            desc = "Bookmarks",
            action = ":lua require('config.picker').bookmarks()",
          },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua require('config.picker').files(nil, {cwd = vim.fn.stdpath('config')})",
          },
          {
            icon = "󰒲 ",
            key = "L",
            desc = "Lazy",
            action = ":Lazy",
            enabled = package.loaded.lazy ~= nil,
          },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = function(dashboard)
        local sections = {}

        if dashboard:size().width >= dashboard_header_width then
          sections[#sections + 1] = {
            pane = 1,
            text = dashboard_header_text(dashboard_header_left),
            padding = 2,
          }
          sections[#sections + 1] = {
            pane = 2,
            text = dashboard_header_text(dashboard_header_right),
            padding = 2,
          }
        else
          sections[#sections + 1] = { section = "header" }
        end

        sections[#sections + 1] = { section = "keys", gap = 1, padding = 1 }
        sections[#sections + 1] = {
          pane = 2,
          icon = " ",
          title = "Recent Files",
          section = "recent_files",
          indent = 2,
          padding = 1,
        }
        sections[#sections + 1] = {
          pane = 2,
          icon = " ",
          title = "Projects",
          section = "projects",
          indent = 2,
          padding = 1,
        }
        sections[#sections + 1] = {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git status --short --branch --renames",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        }
        sections[#sections + 1] = { section = "startup" }

        return sections
      end,
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
