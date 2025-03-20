return {
  {
    "kristijanhusak/vim-dadbod-completion",
    config = function()
      local ok, cmp = pcall(require, "cmp")
      if ok then
        for _, file_type in ipairs({ "sql", "mysql", "plsql" }) do
          cmp.setup.filetype(file_type, {
            sources = cmp.config.sources({
              { name = "vim-dadbod-completion" },
            }),
          })
        end
      end
    end,
    import = "plugins.config.vim-dadbod-completion",
  },
}
