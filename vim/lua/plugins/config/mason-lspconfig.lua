local python_root_files = {
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'Pipfile',
  'pyrightconfig.json',
	'libpython*.dylib',  -- add this one to search in built-in libs
  '.git',
}

local configs = {
	["basedpyright"] = {
    root_dir = function(fname)
			local util = require 'lspconfig.util'
      return util.root_pattern(unpack(python_root_files))(fname)
    end,
	},
	["pyright"] = {
    root_dir = function(fname)
			local util = require 'lspconfig.util'
      return util.root_pattern(unpack(python_root_files))(fname)
    end,
	},
	["harper_ls"] = {
		settings = {
			["harper-ls"] = {
				linters = {
					-- Use typos for spell checking
					spell_check = false,
					-- do not care capitalization
					sentence_capitalization = false,
				}
			}
		},
	},
	["lua_ls"] = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
			},
		},
	},
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
		return opts
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
		return opts
	end,
}

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

			local ok, blink = pcall(require, "blink.cmp")
			if ok then
				opts["capabilities"] = blink.get_lsp_capabilities({}, true)
			else
				local ok2, cmp = pcall(require, "cmp_nvim_lsp")
				if ok2 then
					-- https://github.com/hrsh7th/cmp-nvim-lsp/issues/38#issuecomment-1815265121
					local capabilities = vim.tbl_deep_extend(
						"force",
						vim.lsp.protocol.make_client_capabilities(),
						cmp.default_capabilities()
					)
					opts["capabilities"] = capabilities
				end
			end

			return opts
		end

		local self_managed_servers = { "tsserver", "ts_ls", "rubocop" }
		local res = {
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
			},
		}

		for k, v in pairs(configs) do
			res.handlers[k] = function()
				local o = v
				if type(v) == "function" then
					o = v()
				end
				local opts = vim.tbl_deep_extend("keep", o, default_opts())

				require("lspconfig")[k].setup(opts)
			end
		end

		return res
	end,
}
