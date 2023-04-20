" https://github.com/simrat39/symbols-outline.nvim
lua<<EOF
require("symbols-outline").setup({
  autoclose = true
})
EOF

map  <silent> <F9> :SymbolsOutline<CR>
map! <silent> <F9> :SymbolsOutline<CR>
