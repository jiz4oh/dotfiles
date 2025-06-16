-- Declare a global function to retrieve the current directory
function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    -- If there is no current directory (e.g. over ssh), just show the buffer name
    return vim.api.nvim_buf_get_name(0)
  end
end

local toggle = function(...)
  if vim.b.oil_ready then
    require("oil").close()
  else
    require("oil").open(...)
  end
end

---@type LazyPluginSpec
return {
  "stevearc/oil.nvim",
  optional = true,
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open oil file browser on parent directory", mode = "n" },
    {
      "_",
      "<CMD>execute 'Oil ' . getcwd()<CR>",
      desc = "Open oil file browser on cwd directory",
      mode = "n",
    },
    {
      "<Plug><ExpoloreCfile>",
      "<CMD>Oil<CR>",
      desc = "Open oil file browser on current file",
      mode = "n",
      remap = true,
    },
    {
      "<Plug><ExpoloreToggle>",
      toggle,
      desc = "Toggle oil file browser",
      mode = { "n", "i", "v" },
      remap = true,
    },
    {
      "<Plug><ExpoloreRoot>",
      "<CMD>execute 'Oil ' . getcwd()<CR>",
      desc = "Open oil file browser on cwd directory",
      mode = "n",
      remap = true,
    },
  },
  specs = {
    "preservim/nerdtree",
    enabled = false,
  },
  event = {
    "BufEnter",
    "BufNew",
    "FileType",
  },
  -- specs = {
  --   { "preservim/nerdtree", enabled = false },
  -- },
  lazy = false,
  ---@type oil.setupOpts
  opts = {
    delete_to_trash = true,
    win_options = {
      winbar = "%!v:lua.get_oil_winbar()",
    },
    keymaps = {
      ["q"] = { "actions.close", mode = "n" },
      ["K"] = {
        desc = "Toggle file detail view",
        callback = function()
          detail = not detail
          if detail then
            require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
          else
            require("oil").set_columns({ "icon" })
          end
        end,
      },
      ["<m-r>"] = {
        desc = "Discard All Changes",
        callback = function()
          require("oil").discard_all_changes()
        end,
      },
      ["<backspace>"] = { "actions.parent", mode = "n" },
      ["<C-v>"] = { "actions.select", opts = { vertical = true } },
      ["?"] = { "actions.show_help", mode = "n" },
      ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
      ["<C-s>"] = { "<cmd>update<cr>" },
      ["y."] = { "actions.yank_entry", buffer = true, mode = "n", nowait = true },
      ["y<C-g>"] = {
        function()
          local config = require("oil.config")
          local fs = require("oil.fs")
          local bufname = vim.api.nvim_buf_get_name(0)
          local scheme, path = require("oil.util").parse_url(bufname)
          if not scheme or not path then
            return
          end
          local adapter = config.get_adapter_by_scheme(scheme)
          if not adapter or adapter.name ~= "files" then
            return
          end
          local path = fs.posix_to_os_path(path)
          vim.fn.setreg(vim.v.register, path)
        end,
        buffer = true,
        mode = "n",
        nowait = true,
      },
      ["<C-h>"] = false,
      ["<C-l>"] = false,
      ["<leader>!"] = {
        function()
          local config = require("oil.config")
          local bufname = vim.api.nvim_buf_get_name(0)
          local adapter = config.get_adapter_by_scheme(bufname)

          require("oil.actions").open_terminal.callback()
          local term_id = vim.bo.channel
          vim.cmd.startinsert()
          if adapter.name == "ssh" then
            local url = require("oil.adapters.ssh").parse_url(bufname)
            local cmd = require("oil.adapters.ssh.connection").create_ssh_command(url)
            -- 判断是否是 qnap
            table.insert(cmd, "uname -a | grep -qi qnap >/dev/null 2>&1")
            local code = -1
            vim
              .system(cmd, {}, function(obj)
                code = obj.code
              end)
              :wait()
            if code == 0 then
              vim.defer_fn(function()
                vim.api.nvim_chan_send(term_id, "q\ny\n")
                vim.defer_fn(function()
                  vim.api.nvim_chan_send(term_id, string.format("cd %s\n", url.path))
                end, 100)
              end, 300)
            end
          end
        end,
        mode = "n",
      },
      ["<leader>:"] = {
        "actions.open_cmdline",
        opts = {
          shorten_path = true,
          modify = ":h",
        },
        desc = "Open the command line with the current directory as an argument",
      },
    },
  },
}
