local self_managed_servers = { "tsserver", "ts_ls", "rubocop" }

---@type LazyPluginSpec
return {
  "williamboman/mason-lspconfig.nvim",
  optional = true,
  dependencies = {
    "williamboman/mason.nvim",
  },
  opts = {
    handlers = {
      -- The first entry (without a key) will be the default handler
      -- and will be called for each installed server that doesn't have
      -- a dedicated handler.
      function(server_name) -- default handler (optional)
        for _, name in ipairs(self_managed_servers) do
          if server_name == name then
            return
          end
        end

        if vim.fn.has("nvim-0.11") == 1 then
          vim.lsp.enable(server_name)
        end
      end,
    },
  },
}
