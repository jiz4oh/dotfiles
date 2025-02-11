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
  lazy = false,
	opts = {
		behaviour = {
			-- auto_set_keymaps = false,
		},
		provider = type(os.getenv("ANTHROPIC_API_KEY")) == type('') and "claude" or "copilot",
		auto_suggestions_provider = "copilot",
		copilot = {
			model = vim.g.copilot_model or "gpt-40-2024-08-06",
		},
		claude = {
			endpoint = os.getenv("ANTHROPIC_ENDPOINT") or "https://api.anthropic.com",
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "Avante",
			callback = function()
				-- remove <Esc> mapping since it's used to close the sidebar
				-- https://github.com/yetone/avante.nvim/blob/57311bf8cd2f48729565d2351bcbf383b6a56907/lua/avante/sidebar.lua#L1867-L1870
				vim.keymap.set("n", "<Esc>", "<Nop>", { buffer = 0 })
			end,
		})
	end,
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
		--- The below dependencies are optional,
		"zbirenbaum/copilot.lua", -- for providers='copilot'
	},
}
