lua << EOF
require("copilot").setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
  copilot_node_command = vim.fn.expand("$ASDF_DIR") .. "/installs/nodejs/20.10.0/bin/node"
})
EOF
