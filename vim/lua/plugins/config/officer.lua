---@type LazyPluginSpec
return {
  "pianocomposer321/officer.nvim",
  optional = true,
  cmd = {
    "Make",
    "Run",
  },
  keys = {
    { "m<SPACE>", "<cmd>Make<SPACE>", desc = nil, mode = "n" },
    { "m<CR>", "<cmd>Make<CR>", desc = nil, mode = "n" },
    { "m!", "<cmd>Make!<SPACE>", desc = nil, mode = "n" },
    { "M<SPACE>", "<cmd>Run<SPACE>", desc = nil, mode = "n" },
    { "M<CR>", "<cmd>Run<CR>", desc = nil, mode = "n" },
    { "M!", "<cmd>Run!<SPACE>", desc = nil, mode = "n" },
  },
  opts = {
    create_mappings = true,
  },
  dependencies = {
    import = "plugins.config.overseer",
  },
}
