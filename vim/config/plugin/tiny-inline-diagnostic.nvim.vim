let g:ale_virtualtext_cursor             = 0

lua<<EOF
vim.diagnostic.config({ virtual_text = false })

require('tiny-inline-diagnostic').setup({
CursorLine = { bg = "None" },
hi = {
		error = "DiagnosticError",
		warn = "DiagnosticWarn",
		info = "DiagnosticInfo",
		hint = "DiagnosticHint",
		arrow = "NonText",
		background = "None", -- Can be a highlight or a hexadecimal color (#RRGGBB)
		mixing_color = "None", -- Can be None or a hexadecimal color (#RRGGBB). Used to blend the background color with the diagnostic background color with another color.
	},
})
EOF
