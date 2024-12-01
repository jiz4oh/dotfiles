return {
	"miversen33/netman.nvim",
	event = "CmdlineEnter",
	cmd = {
		"NmloadProvider",
		"Nmlogs",
		"Nmdelete",
		"Nmread",
		"Nmwrite",
	},
	lazy = not (vim.fn.argc() > 0),
	opts = {},
}
