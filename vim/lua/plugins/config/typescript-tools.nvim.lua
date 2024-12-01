-- https://github.com/hinell/lsp-timeout.nvim/issues/12#issuecomment-1779816239
local ts_filetypes = {
	"javascript",
	"js",
	"jsx",
	"ts",
	"tsx",
	"typescript",
	"javascriptreact",
	"javascript.jsx",
	"typescript",
	"typescriptreact",
	"typescript.tsx",
}

return {
	"pmizio/typescript-tools.nvim",
	enabled = vim.g.as_ide == 1,
	ft = ts_filetypes,
	opts = {
		filetypes = ts_filetypes,
	},
}
