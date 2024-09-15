lua<<EOF
require("which-key").setup {
  win = {
    -- don't allow the popup to overlap with the cursor
    no_overlap = false,
  }
}
EOF
