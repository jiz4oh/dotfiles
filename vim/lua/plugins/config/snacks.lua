local lsp_handlers = {
	["textDocument/declaration"] = function(err, result, ctx, config)
		Snacks.picker.lsp_declarations({unique_lines = true})
	end,
	["textDocument/definition"] = function(err, result, ctx, config)
		Snacks.picker.lsp_definitions({unique_lines = true})
	end,
	["textDocument/documentSymbol"] = function(err, result, ctx, config)
		Snacks.picker.lsp_symbols()
	end,
	["textDocument/implementation"] = function(err, result, ctx, config)
		Snacks.picker.lsp_implementations({unique_lines = true})
	end,
	["textDocument/references"] = function(err, result, ctx, config)
		Snacks.picker.lsp_references({unique_lines = true, include_declaration = false})
	end,
	["textDocument/typeDefinition"] = function(err, result, ctx, config)
		Snacks.picker.lsp_type_definitions({unique_lines = true})
	end,
	["workspace/symbol"] = function(err, result, ctx, config)
		Snacks.picker.lsp_workspace_symbols()
	end,
}

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{
			"]]",
			function()
				Snacks.words.jump(vim.v.count1)
			end,
			desc = "Next Reference",
			mode = { "n" },
		},
		{
			"[[",
			function()
				Snacks.words.jump(-vim.v.count1)
			end,
			desc = "Prev Reference",
			mode = { "n" },
		},
		{
			"<leader>sf",
			function()
				Snacks.picker()
			end,
			desc = "Open Snacks Pickers",
			mode = { "n" },
		},
	},
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		quickfile = {
			enabled = true,
			exclude = { "latex" },
		},
		input = {},
		picker = {
			ui_select = true,
			win = {
				-- input window
				input = {
					keys = {
						-- to close the picker on ESC instead of going to normal mode,
						-- add the following keymap to your config
						["/"] = "toggle_focus",
					},
				},
			},
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				if Snacks == nil then
					return
				end
				-- Setup some globals for debugging (lazy-loaded)
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd -- Override print to use snacks for `:=` command

				-- Create some toggle mappings
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.line_number():map("<leader>ul")
				Snacks.toggle
					.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
					:map("<leader>uc")
				Snacks.toggle.treesitter():map("<leader>uT")
				Snacks.toggle
					.option("background", { off = "light", on = "dark", name = "Dark Background" })
					:map("<leader>ub")
				Snacks.toggle.inlay_hints():map("<leader>uh")

				for _, m in ipairs(vim.tbl_keys(lsp_handlers)) do
					vim.lsp.handlers[m] = lsp_handlers[m]
				end
			end,
		})
	end,
}
