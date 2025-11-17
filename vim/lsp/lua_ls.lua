return {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
        -- https://github.com/LuaLS/vscode-lua/blob/fb6694c6aab4ecbceeff1b23d8d5d9aee268ccdd/setting/schema.json#L2507-L2515
        unusedLocalExclude = {
          "_*",
        },
      },
      hint = {
        enable = true,
      },
    },
  },
}
