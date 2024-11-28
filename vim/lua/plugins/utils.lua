return {
	-- https://lazy.folke.io/developers#best-practices
	{ "nvim-lua/plenary.nvim", lazy = true },
	{
		"folke/which-key.nvim",
		enabled = vim.fn.has("nvim-0.10") == 1,
		event = "VeryLazy",
		config = function()
			require("which-key").setup({
				win = {
					-- don't allow the popup to overlap with the cursor
					no_overlap = false,
				},
			})
			local maps = {}

			local function convert(prefix, mode, map)
				for k, v in pairs(map) do
					if k == "name" then
						maps[#maps + 1] = { prefix, mode = mode, group = v }
					else
						if type(v) == "string" then
							maps[#maps + 1] = { prefix .. k, mode = mode, desc = v }
						elseif type(v) == "table" then
							if v[1] ~= nil then
								if string.match(v[1], "^:.*") then
									maps[#maps + 1] = { prefix .. k, v[1] .. "<cr>", mode = mode, desc = v[2] }
								else
									maps[#maps + 1] = { prefix .. k, v[1], mode = mode, desc = v[2] }
								end
							else
								convert(prefix .. k, mode, v)
							end
						else
						end
					end
				end
			end

			convert("<leader>", "n", vim.g.which_key_map)
			convert("<leader>", "v", vim.g.which_key_map_visual)

			maps[#maps + 1] = {
				{
					"<leader>b",
					group = "buffers",
					expand = function()
						return require("which-key.extras").expand.buf()
					end,
				},
			}

			require("which-key").add(maps)
		end,
	},
	{
		"williamboman/mason.nvim",
		lazy = true,
		cmd = { "Mason", "MasonInstall" },
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		cmd = {
			"MasonToolsInstall",
			"MasonToolsUpdate",
		},
		opts = {
			-- a list of all tools you want to ensure are installed upon
			-- start
			ensure_installed = {
				-- you can pin a tool to a particular version

				-- you can turn off/on auto_update per tool
				{ "bash-language-server", auto_update = true },
				"shellcheck",
				"shfmt",

				"vim-language-server",
				"vint",

				-- {{{go tools
				"gopls",
				"golangci-lint",
				"goimports",
				"golines",
				"gomodifytags",
				"gotests",
				"impl",
				"json-to-struct",
				"staticcheck",
				-- }}}

				"lua-language-server",
				"stylua",

				"typescript-language-server",
				"jq",
				"fixjson",

				"typos_lsp",

				"yaml-language-server",
				"yamllint",

				"ruff",

				"rubocop",
				"rubyfmt",
			},

			-- if set to true this will check each tool for updates. If updates
			-- are available the tool will be updated. This setting does not
			-- affect :MasonToolsUpdate or :MasonToolsInstall.
			-- Default: false
			auto_update = false,

			-- automatically install / update on startup. If set to false nothing
			-- will happen on startup. You can use :MasonToolsInstall or
			-- :MasonToolsUpdate to install tools and check for updates.
			-- Default: true
			run_on_start = true,

			-- set a delay (in ms) before the installation starts. This is only
			-- effective if run_on_start is set to true.
			-- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
			-- Default: 0
			start_delay = 3000, -- 3 second delay

			-- Only attempt to install if 'debounce_hours' number of hours has
			-- elapsed since the last time Neovim was started. This stores a
			-- timestamp in a file named stdpath('data')/mason-tool-installer-debounce.
			-- This is only relevant when you are using 'run_on_start'. It has no
			-- effect when running manually via ':MasonToolsInstall' etc....
			-- Default: nil
			debounce_hours = 5, -- at least 5 hours between attempts to install/update

			-- By default all integrations are enabled. If you turn on an integration
			-- and you have the required module(s) installed this means you can use
			-- alternative names, supplied by the modules, for the thing that you want
			-- to install. If you turn off the integration (by setting it to false) you
			-- cannot use these alternative names. It also suppresses loading of those
			-- module(s) (assuming any are installed) which is sometimes wanted when
			-- doing lazy loading.
			integrations = {
				["mason-lspconfig"] = true,
				["mason-null-ls"] = true,
				["mason-nvim-dap"] = true,
			},
		},
		dependencies = {
			"williamboman/mason.nvim",
		},
	},
}
