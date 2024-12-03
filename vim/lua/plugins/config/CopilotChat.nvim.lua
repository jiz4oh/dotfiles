return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{ "zbirenbaum/copilot.lua" },
		{ "nvim-lua/plenary.nvim" },
	},
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
		{ "<leader>af", "<cmd>CopilotChatFix<cr>" },
		{ "<leader>ad", "<cmd>CopilotChatDocs<cr>" },
		{ "<leader>at", "<cmd>CopilotChatTests<cr>" },
		{ "<leader>ao", "<cmd>CopilotChatOptimize<cr>" },
		{ "<leader>ae", "<cmd>CopilotChatExplain<cr>" },
		{ "<leader>ar", "<cmd>CopilotChatReview<cr>" },
		{ "cc", "<cmd>CopilotChatCommit<cr>", ft = "gitcommit" },
	},
	branch = "main",
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
}
