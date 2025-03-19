local ctags = {
	program = "ctags",
	filetypes = {
		go = {
			kinds = {
				func = "Function",
				talias = "TypeAlias",
				methodSpec = "Function",
				var = "Variable",
				const = "Constant",
				type = "TypeParameter",
				packageName = "Module",
			},
		},
	},
}

return {
	{
		"liuchengxu/vista.vim",
    enabled = false,
	},
	{
		"hedyhli/outline.nvim",
		keys = {
			{
				"<Plug><OutlineToggle>",
				"<cmd>Outline<CR>",
				mode = "n",
				desc = "Toggle Outline",
			},
		},
		cmd = { "Outline", "OutlineOpen" },
		opts = {
			-- Your setup opts here
			providers = {
				priority = { "ripper-tags", "lsp", "markdown", "man", "treesitter", "ctags" },
				-- Configuration for each provider (3rd party providers are supported)
				lsp = {
					-- Lsp client names to ignore
					blacklist_clients = {},
				},
				ctags = ctags,
				markdown = {
					-- List of supported ft's to use the markdown provider
					filetypes = { "markdown" },
				},
			},
		},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			{
				"epheien/outline-ctags-provider.nvim",
				enabled = vim.fn.executable("ctags") == 1,
			},
			{
				"epheien/outline-treesitter-provider.nvim",
				enabled = vim.g.with_treesitter == 1,
			},
		},
	},
}
