local enabled = vim.g.as_ide == 1 and vim.fn.has("nvim-0.10") == 1

return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		enabled = enabled,
	},
	{
		"yetone/avante.nvim",
		enabled = enabled,
	},
}
