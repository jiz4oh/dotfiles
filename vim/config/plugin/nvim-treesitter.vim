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
      disable = {'git', 'gitcommit', 'json'},
      additional_vim_regex_highlighting = {'embedded_template', 'ruby'},
    },
    endwise = {
      enable = true,
    },
    textobjects = {
      -- syntax-aware textobjects
      enable = true,
      keymaps = {
        ["iL"] = {
          -- you can define your own textobjects directly here
          go = "(function_definition) @function",
        },
        -- or you use the queries from supported languages with textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["is"] = "@statement.inner",
        ["as"] = "@statement.outer",
        ["ad"] = "@comment.outer",
        ["am"] = "@call.outer",
        ["im"] = "@call.inner"
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer"
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer"
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer"
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer"
        }
      },
    },
  }
EOF
