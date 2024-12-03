if exists('*FzfGrepMap')
  call FzfGrepMap('<leader>sg', 'Packages')
endif

augroup vim-bundler-augroup
  autocmd!

  autocmd! FileType ruby,eruby if !empty(bundler#project()) && bundler#project().has('solargraph') | let b:ale_ruby_solargraph_executable = 'bundle exec solargraph' | endif

  autocmd FileType ruby
        \ if !empty(bundler#project()) && bundler#project().has('rubocop') |let b:ale_ruby_rubocop_executable = 'bundle'|endif
augroup END
