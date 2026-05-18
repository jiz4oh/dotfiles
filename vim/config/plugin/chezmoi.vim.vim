let g:chezmoi#use_tmp_buffer = 1

" Ensure chezmoi.vim filetype detector is loaded even when plugin manager
" initializes after `filetype on`.
if exists('g:plugs') && has_key(g:plugs, 'chezmoi.vim')
  let s:chezmoi_filetype = g:plugs['chezmoi.vim'].dir . '/filetype.vim'
  if filereadable(s:chezmoi_filetype)
    execute 'source ' . fnameescape(s:chezmoi_filetype)
  endif
  unlet s:chezmoi_filetype
endif
