let g:ale_virtualtext_cursor = 0

lua<<EOF
require('diagflow').setup({
  padding_top = 1,
  -- https://github.com/dgagn/diagflow.nvim/issues/54
  -- padding_right = 2,
  show_borders = true,
  format = my_diagnostic_format_func,
})
EOF
