return {
	{
		"VidocqH/data-viewer.nvim",
		ft = { "csv", "tsv" },
		enabled = vim.fn.has("nvim-0.8") == 1,
		opts = {
			autoDisplayWhenOpenFile = true,
			maxLineEachTable = 100,
			columnColorEnable = true,
			columnColorRoulette = { -- Highlight groups
				"DataViewerColumn0",
				"DataViewerColumn1",
				"DataViewerColumn2",
			},
			view = {
				float = true, -- False will open in current window
				width = 0.8, -- Less than 1 means ratio to screen width, valid when float = true
				height = 0.8, -- Less than 1 means ratio to screen height, valid when float = true
				zindex = 50, -- Valid when float = true
			},
			keymap = {
				quit = "q",
				next_table = "<C-l>",
				prev_table = "<C-h>",
			},
		},
		dependencies = {
			-- "kkharji/sqlite.lua", -- Optional, sqlite support
		},
	},
	{
		"adriaanzon/vim-textobj-matchit",
		dependencies = {
			"kana/vim-textobj-user",
		},
	},
	{
		"andrewferrier/debugprint.nvim",
	},
}
