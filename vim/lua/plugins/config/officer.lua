---@type LazyPluginSpec
return {
  "pianocomposer321/officer.nvim",
  opts = {
    create_mappings = true,
  },
  dependencies = {
    import = "plugins.config.overseer",
  },
}
