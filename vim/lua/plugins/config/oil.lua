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

---@type LazyPluginSpec
return {
  "stevearc/oil.nvim",
  optional = true,
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory", mode = "n" },
    { "_", "<CMD>execute 'Oil ' . getcwd()<CR>", desc = "Open cwd directory", mode = "n" },
    { "<Plug><ExpoloreCfile>", "<CMD>Oil<CR>", desc = "Open parent directory", mode = "n", remap = true },
    { "<Plug><ExpoloreToggle>", "<CMD>Oil<CR>", desc = "Open parent directory", mode = { "n", "i", "v" }, remap = true },
    { "<Plug><ExpoloreRoot>", "<CMD>execute 'Oil ' . getcwd()<CR>", desc = "Open cwd directory", mode = "n", remap = true },
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
      ["<backspace>"] = { "actions.parent", mode = "n" },
      ["<C-v>"] = { "actions.select", opts = { vertical = true } },
      ["?"] = { "actions.show_help", mode = "n" },
      ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
      ["<C-g>"] = { "actions.yank_entry", nowait = true },
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
