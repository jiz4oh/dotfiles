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
			enable_cursor_planning_mode = true,
		},
		cursor_applying_provider = type(os.getenv("OPENROUTER_API_KEY")) == type("") and nil or "groq", -- In this example, use Groq for applying, but you can also use any provider you want.
		provider = type(os.getenv("OPENROUTER_API_KEY")) == type("") and "openrouter_claude" or "copilot",
		vendors = {
			groq = { -- define groq provider
				__inherited_from = "openai",
				api_key_name = "ONEHUB_API_KEY",
				endpoint = os.getenv("ONEHUB_BASE_URL"),
				model = "llama-3.3-70b-versatile",
				max_tokens = 32768, -- remember to increase this value, otherwise it will stop generating halfway
			},
			openrouter = {
				__inherited_from = "openai",
				endpoint = "https://openrouter.ai/api/v1",
				api_key_name = "OPENROUTER_API_KEY",
				model = "deepseek/deepseek-r1",
			},
			openrouter_claude = {
				__inherited_from = "openai",
				endpoint = "https://openrouter.ai/api/v1",
				api_key_name = "OPENROUTER_API_KEY",
				use_xml_format = true,
				model = "anthropic/claude-3.7-sonnet",
				parse_messages = function(opts)
					require("avante.providers").claude.parse_messages(opts)
				end,
				parse_curl_args = function(provider, prompt_opts)
					local args = require("avante.providers").openai.parse_curl_args(provider, prompt_opts)
					return vim.tbl_deep_extend("force", args, {
						body = {
							system = {
								{
									type = "text",
									text = prompt_opts.system_prompt,
									cache_control = { type = "ephemeral" },
								},
							},
						},
					})
				end,
			},
		},
		file_selector = {
			provider = "snacks",
		},
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
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		--- The below dependencies are optional,
		"zbirenbaum/copilot.lua", -- for providers='copilot'
	},
}
