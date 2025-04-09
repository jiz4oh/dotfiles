---@type LazyPluginSpec
return {
  "preservim/nerdtree",
  optional = true,
  cmd = {
    "NERDTree",
    "NERDTreeToggle",
    "NERDTreeFind",
  },
  lazy = true,
  dependencies = {
    { "Xuyuanp/nerdtree-git-plugin" },
    { "PhilRunninger/nerdtree-visual-selection" },
  },
}
