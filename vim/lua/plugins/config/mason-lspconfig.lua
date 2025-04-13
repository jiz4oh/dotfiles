local default_opts = {
  flags = {
    debounce_text_changes = 100,
  },
}

local python_root_files = {
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  "pyrightconfig.json",
  "libpython*.dylib", -- add this one to search in built-in libs
  ".git",
}

local configs = {
  ["gopls"] = {
    settings = {
      gopls = {
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  },
  ["basedpyright"] = {
    root_markers = python_root_files,
  },
  ["pyright"] = {
    root_markers = python_root_files,
  },
  ["harper_ls"] = {
    settings = {
      ["harper-ls"] = {
        linters = {
          -- Use typos for spell checking
          spell_check = false,
          -- do not care capitalization
          sentence_capitalization = false,
        },
      },
    },
  },
  ["lua_ls"] = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        hint = {
          enable = true,
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

if vim.fn.has("nvim-0.11") ~= 1 then
  configs["basedpyright"] = {
    root_dir = function(fname)
      local util = require("lspconfig.util")
      return util.root_pattern(unpack(python_root_files))(fname)
    end,
  }
  configs["pyright"] = {
    root_dir = function(fname)
      local util = require("lspconfig.util")
      return util.root_pattern(unpack(python_root_files))(fname)
    end,
  }
end

---@type LazyPluginSpec
return {
  "williamboman/mason-lspconfig.nvim",
  optional = true,
  dependencies = {
    "williamboman/mason.nvim",
    "b0o/schemastore.nvim",
  },
  config = function(_, opts)
    -- lazy load cmp_nvim_lsp on demand
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

          local opts = vim.tbl_deep_extend("force", default_opts, opts)
          if vim.fn.has("nvim-0.11") == 1 then
            vim.lsp.config(server_name, opts)
            vim.lsp.enable(server_name)
          else
            require("lspconfig")[server_name].setup(opts)
          end
        end,
      },
    }

    for server_name, config in pairs(configs) do
      res.handlers[server_name] = function()
        local o = config
        if type(config) == "function" then
          o = config()
        end

        local opts = vim.tbl_deep_extend("force", default_opts, opts, o)
        if vim.fn.has("nvim-0.11") == 1 then
          vim.lsp.config(server_name, opts)
          vim.lsp.enable(server_name)
        else
          require("lspconfig")[server_name].setup(opts)
        end
      end
    end

    require("mason-lspconfig").setup(res)
  end,
}
