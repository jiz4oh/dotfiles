local enabled = vim.g.as_ide == 1 and vim.fn.has("nvim-0.10") == 1

return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		enabled = enabled,
		cmd = {
			"CopilotChat",
			"CopilotChatModels",
			"CopilotChatAgents",
			"CopilotChatCommit",
			"CopilotChatToggle",
		},
		keys = {
			{ "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
			{
				"<leader>ac",
				function()
					return require("CopilotChat").toggle()
				end,
				desc = "Toggle (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>ax",
				function()
					return require("CopilotChat").reset()
				end,
				desc = "Clear (CopilotChat)",
				mode = { "n", "v" },
			},
			{ "<leader>af", "<cmd>CopilotChatFix<cr>", },
			{ "<leader>ad", "<cmd>CopilotChatDocs<cr>", },
			{ "<leader>at", "<cmd>CopilotChatTests<cr>", },
			{ "<leader>ao", "<cmd>CopilotChatOptimize<cr>", },
			{ "<leader>ae", "<cmd>CopilotChatExplain<cr>", },
			{ "<leader>ar", "<cmd>CopilotChatReview<cr>", },
			{ "cc", "<cmd>CopilotChatCommit<cr>", ft = 'gitcommit' },
		},
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = function()
			local user = vim.env.USER or "User"
			user = user:sub(1, 1):upper() .. user:sub(2)

			return {
				auto_insert_mode = true,
				question_header = "  " .. user .. " ",
				answer_header = "  Copilot ",
				model = vim.g.copilot_model, -- call CopilotChatModels to check
				chat_autocomplete = true,
				mappings = {
					complete = {
						insert = "",
					},
				},
				window = {
					layout = "float",
					relative = "cursor",
					width = 0.4, -- Changed from 1 to 0.4 (40% of screen width)
					height = 0.4,
					row = 1,
				},
			}
		end,
	},
	{
		"yetone/avante.nvim",
		enabled = enabled,
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
				"<leader>ar",
				function()
					require("avante.api").refresh()
				end,
				desc = "avante: refresh",
			},
			{
				"<leader>ae",
				function()
					require("avante.api").edit()
				end,
				desc = "avante: edit",
				mode = "v",
			},
		},
		cmd = { "AvanteAsk" },
		opts = {
			behaviour = {
				auto_set_keymaps = false,
			},
			provider = "copilot",
			auto_suggestions_provider = "copilot",
			copilot = {
				model = vim.g.copilot_model,
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
	},
}
