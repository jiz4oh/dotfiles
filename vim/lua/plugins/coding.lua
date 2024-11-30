local enabled = vim.g.as_ide == 1

return {
	{
		"L3MON4D3/LuaSnip",
		enabled = enabled,
		lazy = true,
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
		dependencies = {
			"honza/vim-snippets",
		},
	},
	{
		"zbirenbaum/copilot.lua",
		enabled = enabled,
		lazy = true,
		cmd = "Copilot",
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			copilot_node_command = vim.fn.expand("$ASDF_DIR") .. "/installs/nodejs/20.10.0/bin/node",
		},
	},
	{
		"zbirenbaum/copilot-cmp",
		enabled = enabled,
		lazy = true,
		dependencies = {
			"zbirenbaum/copilot.lua",
		},
	},
	{
		"hrsh7th/nvim-cmp",
		enabled = enabled,
		version = false, -- last release is way too old
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-path",
			"lukas-reineke/cmp-under-comparator",
			"saadparwaiz1/cmp_luasnip",
			"roobert/tailwindcss-colorizer-cmp.nvim",
			"quangnguyen30192/cmp-nvim-tags",
			"garyhurtz/cmp_kitty",
			"zbirenbaum/copilot-cmp",
			"onsails/lspkind.nvim",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")

			local default_sources = {
				-- Copilot Source
				{ name = "copilot" },
				{ name = "vim_lsp" },
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
				-- { name = 'vsnip' }, -- For vsnip users.
				{ name = "luasnip" }, -- For luasnip users.
				-- { name = 'ultisnips' }, -- For ultisnips users.
				-- { name = 'snippy' }, -- For snippy users.
				{ name = "cmp_tabnine" },
				{
					name = "kitty",
					option = {
						-- this is where any configuration should be inserted
					},
				},
				{ name = "buffer" },
			}

			local comparators = {
				require("copilot_cmp.comparators").prioritize,
				cmp.config.compare.offset,
				cmp.config.compare.exact,
				cmp.config.compare.score,
				cmp.config.compare.recently_used,
				cmp.config.compare.locality,
				require("cmp-under-comparator").under,
				cmp.config.compare.kind,
				cmp.config.compare.sort_text,
				cmp.config.compare.length,
				cmp.config.compare.order,
			}

			local ok3, tailwindcss_colorizer_cmp = pcall(require, "tailwindcss-colorizer-cmp")

			local lspkind_ops = {
				mode = "symbol_text",
				maxwidth = 50,
				ellipsis_char = "...",
				symbol_map = { Copilot = "" },
			}

			if ok3 then
				lspkind_ops.before = function(entry, vim_item)
					vim_item = tailwindcss_colorizer_cmp.formatter(entry, vim_item)
					return vim_item
				end
			end

			local formatter = require("lspkind").cmp_format(lspkind_ops)

			function load_luasnip()
				local ok, luasnip = pcall(require, "luasnip")
				return ok, luasnip
			end

			-- default config
			-- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua
			cmp.setup({
				sorting = {
					comparators = comparators,
				},
				mapping = cmp.mapping.preset.insert({
					["<M-n>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
					["<M-p>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							if vim.fn.pumvisible() == 1 then
								cmp.complete()
							else
								cmp.select_next_item()
							end
						else
							local ok, luasnip = load_luasnip()
							if ok and luasnip.expand_or_jumpable() then
								luasnip.expand_or_jump()
							else
								fallback()
							end
						end
					end, { "i", "s", "c" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							if vim.fn.pumvisible() == 1 then
								cmp.complete()
							else
								cmp.select_prev_item()
							end
						else
							local ok, luasnip = load_luasnip()
							if ok and luasnip.jumpable(-1) then
								luasnip.jump(-1)
							else
								fallback()
							end
						end
					end, { "i", "s", "c" }),
				}),
				sources = cmp.config.sources(default_sources),
				snippet = {
					expand = function(args)
						local ok, luasnip = load_luasnip()
						if ok then
							luasnip.lsp_expand(args.body) -- For `luasnip` users.
						end
					end,
				},
				formatting = {
					format = formatter,
				},
			})

			for _, filetypee in ipairs({ "vim", "go", "ruby" }) do
				local sources = vim.tbl_deep_extend("force", {}, default_sources)
				table.insert(sources, { name = "tags", group_index = 2 })
				cmp.setup.filetype(filetypee, {
					sources = sources,
				})
			end

			for _, cmd_type in ipairs({ "/", "?", "@" }) do
				cmp.setup.cmdline(cmd_type, {
					mapping = cmp.mapping.preset.cmdline(),
					sources = {
						{ name = "buffer" },
						{ name = "cmdline_history" },
					},
				})
			end

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline({
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "cmdline_history" },
					{ name = "cmdline" },
					{ name = "path" },
				}),
			})

			for _, file_type in ipairs({ "sql", "mysql", "plsql" }) do
				cmp.setup.filetype(file_type, {
					sources = cmp.config.sources({
						{ name = "vim-dadbod-completion" },
					}),
				})
			end
		end,
	},
	{
		enabled = enabled,
		"garyhurtz/cmp_kitty",
		lazy = true,
		config = function()
			require("cmp_kitty"):setup()
		end,
	},
}
