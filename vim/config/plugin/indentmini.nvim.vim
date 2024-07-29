highlight! link IndentLine Whitespace
highlight! link IndentLineCurrent Whitespace

lua<<EOF
require("indentmini").setup({
 exclude = {
    'startify',
    'help',
    'alpha',
    'dashboard',
    'neo-tree',
    'Trouble',
    'lazy',
    'mason',
    'notify',
    'toggleterm',
    'lazyterm',
   },
 char = '▎'
})
EOF
