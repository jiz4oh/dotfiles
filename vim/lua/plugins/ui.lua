local markview = vim.fn.has("nvim-0.10.1") == 1

return {
	-- {
	-- 	"rcarriga/nvim-notify",
	-- 	enabled = vim.fn.has("nvim-0.5") == 1,
	-- 	import = "plugins.config.nvim-notify"
	-- },
	{
		import = "plugins.config.markview",
		enabled = markview,
	},
	{
		"iamcco/markdown-preview.nvim",
		enabled = not markview,
	},
	{
		import = "plugins.config.vim-dadbod-ui"
	}
}
