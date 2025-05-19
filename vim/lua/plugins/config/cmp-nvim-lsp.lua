---@type LazyPluginSpec
return {
  "hrsh7th/cmp-nvim-lsp",
  optional = true,
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/nvim-cmp",
  },
  specs = {
    {
      "williamboman/mason-lspconfig.nvim",
      optional = true,
      opts = function(_, opts)
        if vim.fn.has("nvim-0.11") ~= 1 then
          local cmp = require("cmp_nvim_lsp")
          -- https://github.com/hrsh7th/cmp-nvim-lsp/issues/38#issuecomment-1815265121
          local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            cmp.default_capabilities()
          )
          opts["capabilities"] = capabilities
        end
      end,
    },
  },
  config = function()
    pcall(
      vim.lsp.config,
      "*",
      vim.tbl_deep_extend("force", vim.lsp.config["*"] or {}, {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
    )

    require("cmp_nvim_lsp").setup()
  end,
}
