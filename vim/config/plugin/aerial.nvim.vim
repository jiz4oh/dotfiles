lua<<EOF
local filetypes = { "vim", "go", "ruby" }
require("aerial").setup({
  layout = {
    max_width = { 35, 0.2 },
  },
  backends = { "treesitter", "asciidoc", "man" },
  ignore = {
    filetypes = filetypes,
  },
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    for k,v in pairs(filetypes) do
      if v == vim.bo[bufnr].filetype then
        return
      end
    end

    vim.keymap.set("n", "<Plug><OutlineToggle>", "<cmd>AerialToggle<CR>", { buffer = bufnr, silent = true })
    vim.keymap.set("i", "<Plug><OutlineToggle>", "<c-o><cmd>AerialToggle<CR>", { buffer = bufnr, silent = true })
    vim.keymap.set("n", "<leader>s]", "<cmd>call aerial#fzf()<CR>", { buffer = bufnr, silent = true })
  end,
})
EOF
