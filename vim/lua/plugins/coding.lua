local enabled = vim.g.as_ide == 1

return {
	{
		"L3MON4D3/LuaSnip",
		enabled = enabled,
		import = "plugins.config.LuaSnip"
	},
	{
		enabled = enabled,
		import = "plugins.extras.coding.nvim-cmp"
	},
}
