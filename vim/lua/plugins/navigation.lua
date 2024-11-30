local plugin = {
	{
		"preservim/nerdtree",
		keys = { "<Plug><ExpoloreToggle>" },
		dependencies = {
			{ "Xuyuanp/nerdtree-git-plugin" },
			{ "PhilRunninger/nerdtree-visual-selection" },
		},
	},
	{
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
	},
}

return plugin
