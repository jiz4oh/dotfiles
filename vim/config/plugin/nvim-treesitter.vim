augroup vim-rails-augroup
  autocmd FileType eruby
        \ if RailsDetect() | cmap <buffer><script><expr> <Plug><cfile> rails#ruby_cfile() | endif

augroup END

lua<<EOF
  -- vim.opt.foldmethod = 'expr'
  -- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

  require'nvim-treesitter.configs'.setup {
    auto_install = true,

    ensure_installed = {
      "html",
      "css",
      "tsx",
      "javascript",
      "json",
      "toml",
      "yaml",
      "ruby",
      "go",
    },
    indent = {
      enable = true
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  }
EOF
