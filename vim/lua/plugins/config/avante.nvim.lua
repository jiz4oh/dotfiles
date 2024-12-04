return {
	"yetone/avante.nvim",
	keys = {
		{
			"<leader>aa",
			function()
				require("avante.api").ask()
			end,
			desc = "avante: ask",
			mode = { "n", "v" },
		},
		{
			"<leader>ae",
			function()
				require("avante.api").edit()
			end,
			desc = "avante: edit",
			mode = "v",
		},
		"<Plug>(AvanteAsk)",
		"<Plug>(AvanteToggle)",
		"<Plug>(AvanteChat)",
		"<Plug>(AvanteBuild)",
		"<Plug>(AvanteEdit)",
		"<Plug>(AvanteRefresh)",
		"<Plug>(AvanteFocus)",
	},
	cmd = {
		"AvanteAsk",
		"AvanteToggle",
		"AvanteChat",
		"AvanteBuild",
		"AvanteEdit",
		"AvanteRefresh",
		"AvanteFocus",
		"AvanteSwitchProvider",
		"AvanteClear",
		"AvanteShowRepoMap",
	},
	opts = {
		behaviour = {
			auto_set_keymaps = false,
		},
		provider = "copilot",
		auto_suggestions_provider = "copilot",
		copilot = {
			model = vim.g.copilot_model or "gpt-40-2024-08-06",
		},
		claude = {
			endpoint = os.getenv("ANTHROPIC_ENDPOINT") or "https://api.anthropic.com",
		},
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"zbirenbaum/copilot.lua", -- for providers='copilot'
	},
}
