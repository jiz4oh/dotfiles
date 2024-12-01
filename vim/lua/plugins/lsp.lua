local lsp_enabled = vim.lsp ~= nil and vim.g.as_ide == 1

return {
	{
		"mrded/nvim-lsp-notify",
		enabled = lsp_enabled,
	},
	{
		"hrsh7th/cmp-nvim-lsp",
		enabled = lsp_enabled,
	},
	{
		"hrsh7th/cmp-nvim-lsp-signature-help",
		enabled = lsp_enabled,
	},
	{
		"ojroques/nvim-lspfuzzy",
		enabled = lsp_enabled,
	},
	{
		"pmizio/typescript-tools.nvim",
		enabled = lsp_enabled,
	},
	{
		"zeioth/garbage-day.nvim",
		event = "LspAttach",
		enabled = lsp_enabled and vim.fn.has("nvim-0.10"),
	},
	{
		"williamboman/mason-lspconfig.nvim",
		enabled = lsp_enabled,
	},
	{
		"neovim/nvim-lspconfig",
		enabled = lsp_enabled,
	},
}
