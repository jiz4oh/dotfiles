---@type LazyPluginSpec
return {
  "glacambre/firenvim",
  lazy = false,
  build = ":call firenvim#install(0)",
  init = function()
    vim.g.firenvim_config = {
      globalSettings = {
        alt = "all",
      },
      localSettings = {
        [".*"] = {
          cmdline = "neovim",
          priority = 0,
          selector = "textarea",
          takeover = "never",
        },
      },
    }
  end,
}
