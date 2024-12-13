return {
	{
		"preservim/nerdtree",
		import = "plugins.config.nerdtree"
	},
	{
		"miversen33/netman.nvim",
		import = "plugins.config.netman"
	},
	{
		"stevearc/aerial.nvim",
		enabled = vim.fn.has("nvim-0.9.2") == 1 and vim.g.as_ide == 1,
		import = "plugins.config.aerial"
  }
}
