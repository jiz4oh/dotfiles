if exists('g:project_markers')
  let g:gutentags_project_root = g:project_markers
endif

if executable('ripper-tags')
  let g:gutentags_ctags_executable_ruby = 'ripper-tags'
endif

let g:gutentags_ctags_exclude = [
      \ 'tmp/*', 'log/*', 'coverage/*', 'doc/*', 
      \ '*.git', 
      \ '*.svg', 
      \ '*.hg',
      \ '.idea',
      \ '.vscode',
      \ '.eggs',
      \ '.mypy_cache',
      \ 'venv',
      \ '*/tests/*',
      \ 'build',
      \ 'dist',
      \ '*sites/*/files/*',
      \ 'bin',
      \ 'bazel-*',
      \ 'node_modules',
      \ 'bower_components',
      \ 'cache',
      \ 'compiled',
      \ 'docs',
      \ 'example',
      \ 'bundle',
      \ 'vendor',
      \ '*.md',
      \ '*-lock.json',
      \ '*.lock',
      \ '*bundle*.js',
      \ '*build*.js',
      \ '.*rc*',
      \ '*.json',
      \ '*.min.*',
      \ '*.map',
      \ '*.bak',
      \ '*.zip',
      \ '*.pyc',
      \ '*.class',
      \ '*.sln',
      \ '*.Master',
      \ '*.csproj',
      \ '*.tmp',
      \ '*.csproj.user',
      \ '*.cache',
      \ '*.pdb',
      \ 'tags*',
      \ 'cscope.*',
      \ '*.css',
      \ '*.less',
      \ '*.scss',
      \ '*.exe', '*.dll',
      \ '*.mp3', '*.ogg', '*.flac',
      \ '*.swp', '*.swo',
      \ '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png',
      \ '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
      \ '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx',
      \]

" gotags does not fill the requirement of vim-gutentags
" https://github.com/jstemmer/gotags/issues/28
" if executable('gotags')
"   let g:gutentags_ctags_executable_go = 'gotags'
" endif

let s:tags_dir = expand('~/.cache/vim-tags')
let g:gutentags_cache_dir = s:tags_dir

if !isdirectory(s:tags_dir)
  silent! call mkdir(s:tags_dir, "p", 0700)
endif
