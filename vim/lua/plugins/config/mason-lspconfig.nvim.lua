return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = "williamboman/mason.nvim",
	config = function(_, opts)
		require("mason-lspconfig").setup(opts)
	end,
	opts = function()
		-- lazy load cmp_nvim_lsp on demand
		local function default_opts()
			local opts = {
				flags = {
					debounce_text_changes = 100,
				},
			}

			local ok1, cmp = pcall(require, "cmp_nvim_lsp")
			if ok1 then
				-- https://github.com/hrsh7th/cmp-nvim-lsp/issues/38#issuecomment-1815265121
				local capabilities = vim.tbl_deep_extend(
					"force",
					vim.lsp.protocol.make_client_capabilities(),
					cmp.default_capabilities()
				)
				opts["capabilities"] = capabilities
			end

			return opts
		end

		local self_managed_servers = { "tsserver", "ts_ls", "rubocop" }
		return {
			handlers = {
				-- The first entry (without a key) will be the default handler
				-- and will be called for each installed server that doesn't have
				-- a dedicated handler.
				function(server_name) -- default handler (optional)
					for _, name in ipairs(self_managed_servers) do
						if server_name == name then
							return
						end
					end

					local opts = vim.tbl_deep_extend("keep", {}, default_opts())
					require("lspconfig")[server_name].setup(opts)
				end,
				["lua_ls"] = function()
					local opts = vim.tbl_deep_extend("keep", {
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" },
								},
							},
						},
					}, default_opts())

					require("lspconfig")["lua_ls"].setup(opts)
				end,
				["jsonls"] = function()
					local opts = {}
					local ok1, schemasstore = pcall(require, "schemastore")
					if ok1 then
						opts = {
							settings = {
								json = {
									schemas = schemasstore.json.schemas(),
									validate = { enable = true },
								},
							},
						}
					end

					require("lspconfig")["jsonls"].setup(vim.tbl_deep_extend("keep", opts, default_opts()))
				end,
				["yamlls"] = function()
					local opts = {}
					local ok1, schemasstore = pcall(require, "schemastore")
					if ok1 then
						opts = {
							settings = {
								yaml = {
									schemaStore = {
										-- You must disable built-in schemaStore support if you want to use
										-- this plugin and its advanced options like `ignore`.
										enable = false,
										-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
										url = "",
									},
									schemas = schemasstore.yaml.schemas(),
								},
							},
						}
					end

					require("lspconfig")["yamlls"].setup(vim.tbl_deep_extend("keep", opts, default_opts()))
				end,
			},
		}
	end,
}
