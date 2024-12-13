local enabled = vim.g.as_ide == 1

return {
	{
		"L3MON4D3/LuaSnip",
		enabled = enabled,
		import = "plugins.config.LuaSnip"
	},
	{
		"zbirenbaum/copilot.lua",
		enabled = enabled,
		import = "plugins.config.copilot"
	},
	{
		"zbirenbaum/copilot-cmp",
		enabled = enabled,
		import = "plugins.config.copilot-cmp"
	},
	{
		"hrsh7th/nvim-cmp",
		enabled = enabled,
		import = "plugins.config.nvim-cmp"
	},
	{
		import = "plugins.config.cmp-buffer"
	},
	{
		import = "plugins.config.cmp-cmdline"
	},
	{
		import = "plugins.config.cmp-nvim-tags"
	},
	{
		import = "plugins.config.cmp-path"
	},
	{
		import = "plugins.config.cmp_luasnip"
	},
	{
		"saadparwaiz1/cmp_luasnip",
		enabled = enabled,
		import = "plugins.config.cmp_luasnip"
	},
	{
		"garyhurtz/cmp_kitty",
		enabled = enabled,
		import = "plugins.config.cmp_kitty"
	},
}
