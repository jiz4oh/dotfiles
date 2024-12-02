return {
	{
		"folke/which-key.nvim",
		enabled = vim.fn.has("nvim-0.10") == 1,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	{
		"folke/snacks.nvim",
		enabled = vim.fn.has("nvim-0.9.4") == 1,
	},
	{
		"mhinz/vim-hugefile",
		enabled = vim.fn.has("nvim-0.9.4") == 0,
	},
}
