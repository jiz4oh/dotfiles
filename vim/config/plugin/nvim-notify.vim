lua<<EOF
require("notify").setup({
  stages = "slide",
})
vim.notify = require("notify")
EOF
