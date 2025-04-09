---@type LazyPluginSpec
return {
  "kristijanhusak/vim-dadbod-completion",
  optional = true,
  ft = { "sql", "mysql", "plsql" },
  dependencies = { "tpope/vim-dadbod" },
  lazy = true,
  specs = {
    -- blink.cmp integration
    {
      "saghen/blink.cmp",
      optional = true,
      opts = {
        sources = {
          per_filetype = {
            sql = { "snippets", "dadbod", "buffer" },
          },
          providers = {
            dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
          },
        },
      },
    },
  },
}
