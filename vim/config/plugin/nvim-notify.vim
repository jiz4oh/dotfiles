command! -nargs=1 Echo call v:lua.vim.notify(<q-args>)

lua<<EOF
require("notify").setup({
  stages = "slide",
})
vim.notify = require("notify")
EOF
