local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out =
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.keymap.set("n", "<leader>Lp", "<cmd>Lazy profile<cr>")

local firenvim_plugins = {
  "LazyVim",
  "lazy.nvim",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "nvim-ts-context-commentstring",
  "snacks.nvim",
  "vim-repeat",
  "yanky.nvim",
}

require("lazy").setup({
  root = vim.g["plug_home"] or (vim.fn.stdpath("data") .. "/lazy/bundle"),
  ---@type LazySpec[]
  spec = {
    -- import/override with your plugins
    { import = "vim-plug" },
    -- can override specs from vim-plug
    -- https://lazy.folke.io/usage/structuring#%EF%B8%8F-importing-specs-config--opts
    { import = "plugins" },
    { import = "plugins.lang" },
  },
  concurrency = vim.uv.available_parallelism() * 2,
  defaults = {
    -- Set this to `true` to have all your plugins lazy-loaded by default.
    -- Only do this if you know what you are doing, as it can lead to unexpected behavior.
    lazy = true, -- should plugins be lazy-loaded?
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = nil, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
    -- @type boolean|fun(self:LazyPlugin):boolean|nil
    cond = function(plugin)
      if vim.g.started_by_firenvim then
        return vim.tbl_contains(firenvim_plugins, plugin.name) or plugin.firenvim
      else
        return true
      end
    end,
  },
  install = {
    missing = false,
    colorscheme = { "gruvbox-material" },
  },
  checker = {
    enabled = false, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
