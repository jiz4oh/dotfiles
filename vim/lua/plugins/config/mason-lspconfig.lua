local self_managed_servers = { "tsserver", "ts_ls", "rubocop" }

---@type LazyPluginSpec
return {
  "williamboman/mason-lspconfig.nvim",
  optional = true,
  event = { "FileType" },
  enabled = vim.fn.has("nvim-0.10") == 1,
  dependencies = {
    "williamboman/mason.nvim",
  },
  opts = {
    automatic_enable = {
        exclude = self_managed_servers,
    },
  },
}
