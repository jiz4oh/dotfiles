return {
	"williamboman/mason.nvim",
	cmd = { "Mason", "MasonUpdate" },
	build = ":MasonUpdate",
	config = function()
		require("mason").setup()
	end,
}
