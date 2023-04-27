" https://github.com/simrat39/symbols-outline.nvim
lua<<EOF
require("symbols-outline").setup({
  autoclose = true
})
EOF

function! s:on_lsp_buffer_enabled() abort
  nmap  <buffer><silent> <Plug><OutlineToggle> :SymbolsOutline<CR>
  imap  <buffer><silent> <Plug><OutlineToggle> <c-o>:SymbolsOutline<CR>
endfunction

augroup symbols-outline-augroup
  autocmd!

  autocmd User LspAttach call s:on_lsp_buffer_enabled()
augroup END
