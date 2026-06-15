---@module "lazy"
---@type LazyPluginSpec
return {
  "barrettruth/diffs.nvim",
  optional = true,
  lazy = false,
  init = function()
    vim.g.diffs = {
      integrations = {
        fugitive = true,
        neogit = true,
        neojj = true,
        gitsigns = true,
      },
    }
  end,
}
