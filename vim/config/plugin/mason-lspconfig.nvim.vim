lua<<EOF
require("mason-lspconfig").setup()
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  vim.api.nvim_command("doautocmd <nomodeline> User LspAttach")
end

local opts = {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 100,
  }
}

if 0 ~= vim.fn.HasInstall('cmp-nvim-lsp') then
  opts["capabilities"] = require('cmp_nvim_lsp').default_capabilities()
end

-- https://stackoverflow.com/a/641993
function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

require("mason-lspconfig").setup_handlers {
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function (server_name) -- default handler (optional)
    local default_opts = table.shallow_copy(opts)
    require("lspconfig")[server_name].setup(default_opts)
  end,
  ['lua_ls'] = function ()
    local default_opts = table.shallow_copy(opts)
    default_opts.settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' }
        }
      }
    }

    require("lspconfig")['lua_ls'].setup(default_opts)
  end
}
EOF
