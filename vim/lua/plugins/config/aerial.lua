---@type LazyPluginSpec
return {
  "stevearc/aerial.nvim",
  event = "LspAttach",
  kets = {
    { "<leader>s]", "<cmd>call aerial#fzf()<CR>", buffer = 0, silent = true },
  },
  opts = {
    layout = {
      width = 35,
    },
    backends = { "treesitter", "lsp", "asciidoc", "man" },
    ignore = {
      filetypes = filetypes,
    },
    filter_kind = false,
    show_guides = true,
    placement = "edge",
    -- optionally use on_attach to set keymaps when aerial has attached to a buffer
    on_attach = function(bufnr)
      if "ctags" == vim.g.vista_executive_for[vim.bo[bufnr].filetype] then
        return
      end

      vim.keymap.set(
        "n",
        "<Plug><OutlineToggle>",
        "<cmd>AerialToggle<CR>",
        { buffer = bufnr, silent = true }
      )
      vim.keymap.set(
        "i",
        "<Plug><OutlineToggle>",
        "<c-o><cmd>AerialToggle<CR>",
        { buffer = bufnr, silent = true }
      )
    end,
  },
  -- Optional dependencies
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
}
