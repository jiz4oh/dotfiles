if vim.g.with_treesitter == 0 then
	return {}
end

local plugin = {
	{
		"RRethy/nvim-treesitter-endwise",
		event = "InsertEnter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "VeryLazy",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = true,
		build = ":TSUpdate",
		opts = {
			-- vim.opt.foldmethod = 'expr'
			-- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
			auto_install = true,

			ensure_installed = {
				"html",
				"css",
				"tsx",
				"javascript",
				"json",
				"toml",
				"yaml",
				"ruby",
				"go",
			},
			indent = {
				enable = true,
			},
			highlight = {
				enable = true,
				disable = { "git", "gitcommit", "json" },
				additional_vim_regex_highlighting = { "embedded_template", "ruby" },
			},
			endwise = {
				enable = true,
			},
			textobjects = {
				-- syntax-aware textobjects
				enable = true,
				keymaps = {
					["iL"] = {
						-- you can define your own textobjects directly here
						go = "(function_definition) @function",
					},
					-- or you use the queries from supported languages with textobjects.scm
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["is"] = "@statement.inner",
					["as"] = "@statement.outer",
					["ad"] = "@comment.outer",
					["am"] = "@call.outer",
					["im"] = "@call.inner",
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}

return plugin
