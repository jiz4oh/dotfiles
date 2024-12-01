local enabled = vim.g.as_ide == 1

return {
	{
		"L3MON4D3/LuaSnip",
		enabled = enabled,
	},
	{
		"zbirenbaum/copilot.lua",
		enabled = enabled,
	},
	{
		"zbirenbaum/copilot-cmp",
		enabled = enabled,
	},
	{
		"hrsh7th/nvim-cmp",
		enabled = enabled,
	},
	{
		"garyhurtz/cmp_kitty",
    enabled = enabled,
	},
}
