---@module "lazy"
---@type LazyPluginSpec
return {
  "andymass/vim-matchup",
  init = function()
    -- modify your configuration vars here
    vim.g.matchup_treesitter_stopline = 500
  end,
  ---@type matchup.Config
  opts = {
    treesitter = {
      stopline = 500,
    },
  },
}
