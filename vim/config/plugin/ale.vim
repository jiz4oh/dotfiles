let g:ale_set_quickfix = 0
let g:ale_set_loclist = 0

let g:ale_linters = {
      \   'java': [],
      \   'scala': [],
      \   'clojure': [],
      \   'python': ['flake8', 'pylint', 'ruff'],
      \   'ruby': ['ruby', 'rubocop', 'solargraph'],
      \   'vim': ['vint',],
      \   'go': ['gofmt', 'gopls']
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
      \   'xml': ['xmllint', ],
      \   'html': ['prettier-eslint'],
      \   'css': ['stylelint'],
      \   'scss': ['stylelint'],
      \   'sass': ['stylelint'],
      \   'python': ['ruff_format', 'autocorrect', 'black', 'isort', 'remove_trailing_lines', 'trim_whitespace'],
      \   'ruby': ['rubocop'],
      \   'lua': ['stylua', ],
      \   'sh': ['shfmt', ],
      \   'markdown': ['prettier', 'autocorrect'],
      \   'rust': ['rustfmt', ],
      \   'go': ['gofmt', 'gopls', 'goimports'],
      \   'zeroapi': ['zeroapifmt', 'remove_trailing_lines', 'trim_whitespace', 'autocorrect'],
      \   'eruby': ['erblint', 'remove_trailing_lines', 'trim_whitespace']
      \}

let g:ale_linter_aliases = {
      \ 'html': ['html', 'javascript', 'css'],
      \ 'typescript.tsx': ['typescript', 'jsx'],
      \ 'typescriptreact': ['typescript', 'jsx'],
      \ 'javascript.tsx': ['javascript', 'jsx'],
      \ }

let g:ale_use_global_executables = 1
let g:ale_go_gopls_options = '-remote=auto'
let g:ale_dockerfile_hadolint_use_docker = 'yes'

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

highlight! link ALEVirtualTextError Comment
highlight! link ALEVirtualTextWarning Comment

function! s:toggle_virtualtext_cursor() abort
  if g:ale_virtualtext_cursor == 1
    let g:ale_virtualtext_cursor = 2
    ALEDisableBuffer | ALEEnableBuffer
    let msg = 'all warnings be shown'
  else
    let g:ale_virtualtext_cursor = 1
    ALEDisableBuffer | ALEEnableBuffer
    let msg = 'message will be shown when a cursor is near a warning or error'
  endif
  if has('nvim')
    call v:lua.vim.notify('ALE: ' .. msg, 'info')
  else
    echomsg 'ALE: ' . msg
  end
endfunction

function! s:activate_ale_by_projectionist() abort
  for [_root, options] in projectionist#query('ale')
    if type(options) == type({})
      for [name, value] in items(options)
        call setbufvar(bufnr(), 'ale_' . name, value)
      endfor
    endif
  endfor
endfunction

nmap <leader>ff <Plug>(ale_fix)

nmap <silent> <leader>ft :call <SID>toggle_virtualtext_cursor()<cr>

call ale#fix#registry#Add('zeroapifmt',
      \'ale#fixers#zeroapifmt#Fix', 
      \[
      \'zeroapi',
      \], 
      \'Correct spaces, words, and punctuations between CJK (Chinese, Japanese, Korean). '
      \)

function! FixTypescript(buffer) abort
  try
    TSToolsOrganizeImports
    TSToolsAddMissingImports
    TSToolsFixAll
  catch
  endtry
endfunction

call ale#fix#registry#Add('typescript-tools',
      \'FixTypescript', 
      \[
      \'typescript',
      \'typescript.tsx',
      \], 
      \'add missing imports, sorts and removes unused imports, fixes all fixable errors'
      \)

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

  autocmd User ProjectionistActivate call s:activate_ale_by_projectionist()
augroup END
