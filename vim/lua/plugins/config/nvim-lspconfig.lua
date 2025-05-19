---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  optional = true,
  -- https://github.com/LazyVim/LazyVim/blob/86ac9989ea15b7a69bb2bdf719a9a809db5ce526/lua/lazyvim/plugins/lsp/init.lua#L5
  event = { "BufReadPre", "BufNewFile" },
  specs = {
    {
      "williamboman/mason-lspconfig.nvim",
      optional = true,
    }
  },
  init = function()
    -- do not set tagfunc, it's slowly with cmp-nvim-tags
    TAGFUNC_ALWAYS_EMPTY = function()
      return vim.NIL
    end

    -- if tagfunc is already registered, nvim lsp will not try to set tagfunc as vim.lsp.tagfunc.
    vim.o.tagfunc = "v:lua.TAGFUNC_ALWAYS_EMPTY"
  end,
}
