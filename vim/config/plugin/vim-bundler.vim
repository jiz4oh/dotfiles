if exists('*FzfGrepMap')
  call FzfGrepMap('<leader>sg', 'Packages')
endif

function! s:init_ruby()
  call MyLoad('vim-bundler')
  if !empty(bundler#project())
    if bundler#project().has('solargraph')
      let b:ale_ruby_solargraph_executable = 'bundle exec solargraph'
    endif

    if bundler#project().has('rubocop')
      let b:ale_ruby_rubocop_executable = 'bundle'
    endif
  endif
endfunction

augroup vim-bundler-augroup
  autocmd!

  autocmd! FileType ruby,eruby call s:init_ruby()
augroup END
