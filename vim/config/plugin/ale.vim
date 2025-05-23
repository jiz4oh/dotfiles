let g:ale_set_quickfix = 0
let g:ale_set_loclist = 0

let g:ale_linters = {
      \   'java': [],
      \   'scala': [],
      \   'clojure': [],
      \   'python': ['flake8', 'pylint', 'ruff'],
      \   'ruby': ['ruby', 'rubocop', 'solargraph'],
      \   'vim': ['vint',],
      \   'go': ['gofmt', 'gopls', 'golangci-lint', 'staticcheck']
      \}

let ts_fixers = ['typescript-tools', 'prettier-eslint', 'remove_trailing_lines', 'trim_whitespace', 'autocorrect']
let g:ale_fixers = {
      \   '*': ['remove_trailing_lines', 'trim_whitespace', 'autocorrect'],
      \   'json': ['fixjson', 'jq', 'autocorrect', 'remove_trailing_lines', 'trim_whitespace'],
      \   'yaml': ['prettier', 'autocorrect'],
      \   'javascript': ts_fixers,
      \   'javascript.tsx': ts_fixers,
      \   'typescript': ts_fixers,
      \   'typescript.tsx': ts_fixers,
      \   'typescriptreact': ts_fixers,
      \   'xml': ['xmllint', 'xml_tidy'],
      \   'html': ['prettier-eslint'],
      \   'css': ['stylelint'],
      \   'scss': ['stylelint'],
      \   'sass': ['stylelint'],
      \   'python': ['pyflyby','autocorrect', 'black', 'remove_trailing_lines', 'trim_whitespace', 'ruff_format'],
      \   'ruby': ['rubyfmt', 'rubocop'],
      \   'lua': ['stylua', ],
      \   'sh': ['shfmt', ],
      \   'markdown': ['prettier', 'autocorrect'],
      \   'rust': ['rustfmt', ],
      \   'go': ['gofumpt', 'goimports', 'golines', 'autocorrect'],
      \   'zeroapi': ['zeroapifmt', 'remove_trailing_lines', 'trim_whitespace', 'autocorrect'],
      \   'eruby': ['erblint', 'remove_trailing_lines', 'trim_whitespace']
      \}

let g:ale_linter_aliases = {
      \ 'html': ['html', 'javascript', 'css'],
      \ 'typescript.tsx': ['typescript', 'jsx'],
      \ 'typescriptreact': ['typescript', 'jsx'],
      \ 'javascript.tsx': ['javascript', 'jsx'],
      \ }

"{{{ linter options
let g:ale_use_global_executables = 1
let g:ale_go_gopls_options = '-remote=auto'
let g:ale_dockerfile_hadolint_use_docker = 'yes'
let g:ale_python_pyflyby_options = '-n'
let g:ale_lua_stylua_options = '--search-parent-directories'
let g:ale_xml_xmllint_options = '--encode UTF-8'
"}}}

"{{{ ale options
let g:ale_lint_on_text_changed           = 'always'
let g:ale_lint_delay                     = 750

let g:ale_detail_to_floating_preview     = 1

let g:ale_sign_info                      = 'I'
let g:ale_sign_warning                   = 'W'
let g:ale_sign_error                     = 'E'
let g:ale_echo_msg_warning_str           = 'W'
let g:ale_echo_msg_error_str             = 'E'
let g:ale_echo_msg_format                = '[%severity%] [%linter%] %s'

let g:ale_virtualtext_cursor             = 1
let g:ale_virtualtext_prefix             = '  ◉ '
"}}}

highlight! link ALEVirtualTextError Comment
highlight! link ALEVirtualTextWarning Comment

function! s:toggle_virtualtext_cursor() abort
  if g:ale_virtualtext_cursor == 1
    if get(g:, 'ale_use_neovim_diagnostics_api')
      let g:ale_virtualtext_cursor = 0
      if has('nvim')
        lua vim.diagnostic.enable(false)
      endif
    else
      let g:ale_virtualtext_cursor = 2
    end
    ALEDisableBuffer | ALEEnableBuffer
    let msg = 'all warnings be shown'
  else
    let g:ale_virtualtext_cursor = 1
    if get(g:, 'ale_use_neovim_diagnostics_api')
      if has('nvim')
        lua vim.diagnostic.enable(true)
      endif
    end
    ALEDisableBuffer | ALEEnableBuffer
    let msg = 'message will be shown when a cursor is near a warning or error'
  endif
  if has('nvim')
    call v:lua.vim.notify('ALE: ' .. msg, 'info')
  else
    echomsg 'ALE: ' . msg
  end
endfunction

nmap <leader>ff <Plug>(ale_fix)

nmap <silent> <leader>ft :call <SID>toggle_virtualtext_cursor()<cr>

augroup ale_augroup
  autocmd!

  if !has('nvim-0.6')
    nmap ]d <Plug>(ale_next_wrap)
    nmap [d <Plug>(ale_previous_wrap)
  elseif !has('nvim-0.10.0')
lua<<EOF
  vim.keymap.set('n', ']d', function()
    vim.diagnostic.goto_next({ float = false })
  end, { desc = 'Jump to the next diagnostic' })

  vim.keymap.set('n', '[d', function()
    vim.diagnostic.goto_prev({ float = false })
  end, { desc = 'Jump to the previous diagnostic' })

  vim.keymap.set('n', '<C-W>d', function()
    vim.diagnostic.open_float()
  end, { desc = 'Show diagnostics under the cursor' })

  vim.keymap.set(
    'n',
    '<C-W><C-D>',
    '<C-W>d',
    { remap = true, desc = 'Show diagnostics under the cursor' }
  )
EOF

  endif
augroup END
