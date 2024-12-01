return {
	"garyhurtz/cmp_kitty",
	cond = vim.env.KITTY_WINDOW_ID ~= nil,
	event = { "InsertEnter", "CmdlineEnter" },
	config = function()
		require("cmp_kitty"):setup()
	end,
	dependencies = { "hrsh7th/nvim-cmp" },
}
