local ctags = {
  program = "ctags",
  filetypes = {
    go = {
      kinds = {
        func = "Function",
        talias = "TypeAlias",
        methodSpec = "Function",
        var = "Variable",
        const = "Constant",
        type = "TypeParameter",
        packageName = "Module",
      },
    },
  },
}

---@type LazyPluginSpec
return {
  {
    "liuchengxu/vista.vim",
    optional = true,
    enabled = false,
  },
  {
    "preservim/tagbar",
    optional = true,
    enabled = false,
  },
  {
    "hedyhli/outline.nvim",
    optional = true,
    enabled = vim.fn.has("nvim-0.9") == 1,
    keys = {
      {
        "<Plug><OutlineToggle>",
        "<cmd>Outline<CR>",
        mode = "n",
        desc = "Toggle Outline",
      },
    },
    cmd = { "Outline", "OutlineOpen" },
    opts = {
      -- Your setup opts here
      providers = {
        priority = { "ripper-tags", "lsp", "markdown", "man", "ctags" },
        -- Configuration for each provider (3rd party providers are supported)
        lsp = {
          -- Lsp client names to ignore
          blacklist_clients = {},
        },
        ctags = ctags,
        markdown = {
          -- List of supported ft's to use the markdown provider
          filetypes = { "markdown" },
        },
      },
    },
    opts_extends = { "providers.priority" },
    dependencies = {
      {
        "epheien/outline-ctags-provider.nvim",
        enabled = vim.fn.executable("ctags") == 1,
      },
    },
  },
}
