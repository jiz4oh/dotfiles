-- $VIMRUNTIME/ftplugin/lua.lua
-- override the vim-apathy plugin set
vim.bo.includeexpr = [[v:lua.require'vim._ftplugin.lua'.includeexpr(v:fname)]]
