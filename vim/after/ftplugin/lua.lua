if vim.fn.has("nvim-0.11") == 1 then
  -- $VIMRUNTIME/ftplugin/lua.lua
  -- override the vim-apathy plugin set
  vim.bo.includeexpr = [[v:lua.require'vim._ftplugin.lua'.includeexpr(v:fname)]]
end
