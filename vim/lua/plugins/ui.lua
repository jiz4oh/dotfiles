return {
	{
		"stevearc/dressing.nvim",
		enabled = vim.fn.has("nvim-0.8") == 1,
		import = "plugins.config.dressing"
	},
	{
		"rcarriga/nvim-notify",
		enabled = vim.fn.has("nvim-0.5") == 1,
		import = "plugins.config.nvim-notify"
	},
	{
		import = "plugins.config.vim-dadbod-ui"
	}
}
