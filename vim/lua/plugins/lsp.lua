if vim.lsp == nil then
  return {}
end

-- https://github.com/hinell/lsp-timeout.nvim/issues/12#issuecomment-1779816239
local ts_filetypes = {
  "javascript",
  "js",
  "jsx",
  "ts",
  "tsx",
  "typescript",
  "javascriptreact",
  "javascript.jsx",
  "typescript",
  "typescriptreact",
  "typescript.tsx",
}

return {
  {
    "mrded/nvim-lsp-notify",
    enabled = vim.g.as_ide == 1,
    dependencies = {
      "rcarriga/nvim-notify",
    },
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    enabled = vim.g.as_ide == 1,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
  },
  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    enabled = vim.g.as_ide == 1,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
  },
  {
    "ojroques/nvim-lspfuzzy",
    enabled = vim.g.as_ide == 1,
    opts = {
      methods = "all", -- either 'all' or a list of LSP methods (see below)
      jump_one = true, -- jump immediately if there is only one location
      callback = nil, -- callback called after jumping to a location
      save_last = false, -- save last location results for the :LspFuzzyLast command
      fzf_modifier = ":~:.", -- format FZF entries, see |filename-modifiers|
      fzf_trim = true, -- trim FZF entries
    },
    dependencies = {
      { "junegunn/fzf" },
      { "junegunn/fzf.vim" }, -- to enable preview (optional)
    },
  },
  {
    "pmizio/typescript-tools.nvim",
    enabled = vim.g.as_ide == 1,
    ft = ts_filetypes,
    opts = {
      filetypes = ts_filetypes,
    },
  },
  {
    "zeioth/garbage-day.nvim",
    event = "LspAttach",
    enabled = vim.g.as_ide == 1 and vim.fn.has("nvim-0.10"),
    dependencies = "neovim/nvim-lspconfig",
  },
  {
    "williamboman/mason.nvim",
    lazy = true,
    cmd = { "Mason", "MasonUpdate" },
    build = ":MasonUpdate",
  },
  {
    "williamboman/mason-lspconfig.nvim",
    enabled = vim.g.as_ide == 1,
    lazy = true,
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
          local capabilities =
            vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), cmp.default_capabilities())
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
  },
  {
    "neovim/nvim-lspconfig",
    enabled = vim.g.as_ide == 1,
    event = "VeryLazy",
    keys = {
      {
        "<leader>lr",
        function()
          vim.lsp.buf.references({ includeDeclaration = false })
        end,
      },
      { "<leader>ld", vim.lsp.buf.definition },
      { "<leader>lD", vim.lsp.buf.declaration },
      { "<leader>lt", vim.lsp.buf.type_definition },
      { "<leader>li", vim.lsp.buf.implementation },
      { "<leader>lR", vim.lsp.buf.rename },
      { "<leader>ls", vim.lsp.buf.document_symbol },
      { "<leader>lS", vim.lsp.buf.workspace_symbol },
      { "<leader>lK", vim.lsp.buf.hover },
      { "<leader>la", vim.lsp.buf.code_action },
      { "<leader>la", vim.lsp.buf.code_action },
      { "<leader>lf", vim.lsp.buf.format },
      { "<leader>lf", vim.lsp.buf.format, mode = "x" },
    },
    dependencies = {
      "williamboman/mason.nvim",
      "b0o/schemastore.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    init = function()
      -- do not set tagfunc, it's slowly with cmp-nvim-tags
      TAGFUNC_ALWAYS_EMPTY = function()
        return vim.NIL
      end

      -- if tagfunc is already registered, nvim lsp will not try to set tagfunc as vim.lsp.tagfunc.
      vim.o.tagfunc = "v:lua.TAGFUNC_ALWAYS_EMPTY"
    end,
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          vim.g["vista_" .. vim.api.nvim_get_option_value('filetype', {buf = bufnr}) .. "_executive"] = "nvim_lsp"
          vim.api.nvim_buf_set_var(bufnr, "ale_disable_lsp", 1)

          vim.notify_once("LSP " .. client.name .. " attached")
        end,
      })
    end,
  },
}
