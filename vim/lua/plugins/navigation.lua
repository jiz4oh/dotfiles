return {
	{
		"preservim/nerdtree",
	},
	{
		"miversen33/netman.nvim",
	},
	{
		"stevearc/aerial.nvim",
		enabled = vim.fn.has("nvim-0.9.2") == 1 and vim.g.as_ide == 1,
  }
}
