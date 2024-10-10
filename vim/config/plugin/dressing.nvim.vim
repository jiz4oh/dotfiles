lua<<EOF
require("dressing").setup({
 select = {
    -- Set to false to disable the vim.ui.select implementation
    enabled = true,

    -- Priority list of preferred vim.select implementations
    backend = { "fzf_lua", "fzf", "builtin" },
    fzf = {
      window = {
        width = 0.9,
        height = 0.8,
      },
    },
 }
})
EOF
