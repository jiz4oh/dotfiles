local enabled = vim.g.as_ide == 1 and vim.fn.has("nvim-0.10") == 1

return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		enabled = enabled,
		cmd = {
			"CopilotChat",
			"CopilotChatModels",
			"CopilotChatCommit",
			"CopilotChatToggle",
		},
		keys = {
			"<leader>af",
			"<leader>ad",
			"<leader>at",
			"<leader>ao",
			"<leader>ae",
			"<leader>ar",
			"<leader>ac",
			"<leader>aF",
		},
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		init = function()
			vim.cmd([[
        call personal#op#map('<leader>af', 'CopilotChatFix')
        call personal#op#map('<leader>ad', 'CopilotChatDocs')
        call personal#op#map('<leader>at', 'CopilotChatTests')
        call personal#op#map('<leader>ao', 'CopilotChatOptimize')
        call personal#op#map('<leader>ae', 'CopilotChatExplain')
        call personal#op#map('<leader>ar', 'CopilotChatReview')

        nnoremap <leader>ac :CopilotChatToggle<cr>
        nnoremap <leader>aF :CopilotChatFixDiagnostic<cr>

        augroup copilotchat-nvim_augroup
          autocmd!
          autocmd FileType gitcommit nnoremap <buffer> cc :CopilotChatCommit<cr>
        augroup END
      ]])
		end,
		opts = {
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
		},
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
