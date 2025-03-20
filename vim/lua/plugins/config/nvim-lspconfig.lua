return {
  "neovim/nvim-lspconfig",
  -- https://github.com/LazyVim/LazyVim/blob/86ac9989ea15b7a69bb2bdf719a9a809db5ce526/lua/lazyvim/plugins/lsp/init.lua#L5
  event = { "BufReadPre", "BufNewFile" },
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
        vim.g["vista_" .. vim.api.nvim_get_option_value("filetype", { buf = bufnr }) .. "_executive"] =
          "nvim_lsp"
        vim.api.nvim_buf_set_var(bufnr, "ale_disable_lsp", 1)

        if client.name == "ruff" then
          local ale_linters = vim.b.ale_linters or {}
          ale_linters["python"] = vim.tbl_filter(function(v)
            return v ~= "ruff"
          end, vim.g.ale_linters.python)
          vim.b.ale_linters = ale_linters
        end

        vim.notify_once("LSP " .. client.name .. " attached")
      end,
    })
  end,
}
