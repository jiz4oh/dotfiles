let g:projectionist_transformations = {}
let vscode_tasks = {
    \   'type': 'tasks',
    \   'template': [
    \     '//https://code.visualstudio.com/docs/debugtest/tasks',
    \     '{',
    \     '  "$schema": "https://json.schemastore.org/task.json",',
    \     '  "version": "2.0.0",',
    \     '  "inputs": [',
    \     '  ],',
    \     '  "tasks": [',
    \     '     {',
    \     '       "label": "",',
    \     '       "type": "shell",',
    \     '       "command": "",',
    \     '       "detail": "",',
    \     '       "presentation": {',
    \     '         "revealProblems": "onProblem"',
    \     '       },',
    \     '       "problemMatcher": {',
    \     '         "name": "",',
    \     '         "owner": "",',
    \     '         "severity": "",',
    \     '         "pattern": {',
    \     '           "vim_regexp": "",',
    \     '           "message": 1,',
    \     '           "file": 2',
    \     '         }',
    \     '       },',
    \     '       "options": {',
    \     '         "cwd": "${fileWorkspaceFolder}"',
    \     '       }',
    \     '     }',
    \     '  ]',
    \     '}',
    \   ],
    \ }

"https://gist.github.com/jiz4oh/d763f906c65e302b0162a3c05723138b
let g:projectionist_heuristics = {
      \ '.git/': {
      \   '.git/hooks/*': {'type': 'githook'},
      \   '.github/workflows/*': {'type': 'githubworkflow'},
      \   '.vscode/tasks.json': vscode_tasks,
      \ },
      \ '.hg/|.svn/|.bzr/': {
      \   '.vscode/tasks.json': vscode_tasks,
      \ },
      \ 'package.json': {
      \   '.vscode/tasks.json': vscode_tasks,
      \   '*.js': {
      \      'console': 'node'
      \   },
      \   'pnpm-lock.yaml': {
      \      'dispatch': 'pnpm install'
      \   },
      \   'yarn.lock': {
      \      'dispatch': 'yarn install'
      \   },
      \   'package-lock.json': {
      \      'dispatch': 'npm install'
      \   },
      \ },
      \ 'Gemfile|Rakefile|*.gemspec': {
      \   '.vscode/tasks.json': vscode_tasks,
      \ },
      \ 'requirements.txt|requirements.in|pyproject.toml': {
      \   '.vscode/tasks.json': vscode_tasks,
      \   '*.py': {
      \      'console': 'python',
      \   },
      \   'requirements.txt': {
      \      'dispatch': 'pip install -r %',
      \   },
      \   'pyproject.toml': {
      \      'dispatch': 'pdm install -p %:p:h:S',
      \   },
      \ },
      \ 'go.mod': {
      \   '.vscode/tasks.json': vscode_tasks,
      \   '*.go': {
      \      'dispatch': 'go run %:p:S',
      \      'start': 'air',
      \      'alternate': '{}_test.go',
      \   },
      \   '*_test.go': {
      \      'alternate': '{gotest}.go',
      \   },
      \   'go.mod': {
      \     'alternate': 'go.sum',
      \     'dispatch': 'go mod tidy'
      \   },
      \   'go.sum': {
      \     'alternate': 'go.mod',
      \     'dispatch': 'go mod tidy'
      \   }
      \ },
      \}

function! g:projectionist_transformations.gotest(input, o) abort
  return substitute(a:input, '_test', '', 'g')
endfunction

function! g:projectionist_transformations.vimplugin(input, o) abort
  let input = a:input
  let input = substitute(input, 'vim-', '', 'g')
  let input = substitute(input, '.nvim', '', 'g')
  let input = substitute(input, '.lua', '', 'g')
  let input = substitute(input, '.vim', '', 'g')
  return input
endfunction

let g:projects = []

function! s:activate() abort
  for [_root, options] in projectionist#query('b:')
    if type(options) == type({})
      for [name, value] in items(options)
        call setbufvar(bufnr(), name, value)
      endfor
    endif
  endfor

  for [_root, options] in projectionist#query('w:')
    if type(options) == type({})
      for [name, value] in items(options)
        call setwinvar(winnr(), name, value)
      endfor
    endif
  endfor

  for [_root, options] in projectionist#query('t:')
    if type(options) == type({})
      for [name, value] in items(options)
        call settabvar(tabpagenr(), name, value)
      endfor
    endif
  endfor

  for [_root, options] in projectionist#query('g:')
    if type(options) == type({})
      for [name, value] in items(options)
        execute printf('let g:%s = %s', name, value)
      endfor
    endif
  endfor

  for [root, command] in projectionist#query_exec('console')
    let b:console = '++dir=' . fnameescape(root) .
          \ ' ++title=' . escape(fnamemodify(root, ':t'), '\ ') . '\ console ' .
          \ command
    break
  endfor

  for [root, command] in projectionist#query_exec('server')
    let b:server = '++dir=' . fnameescape(root) .
          \ ' ++title=' . escape(fnamemodify(root, ':t'), '\ ') . '\ server ' .
          \ command
    break
  endfor

  if exists('*repeat')
    map <silent> <Plug>UpwardProject :call <SID>up_project()<bar>silent! call repeat#set("\<Plug>UpwardProject", v:count)<cr>
  else
    noremap <silent> <Plug>UpwardProject :call <SID>up_project()<cr>
  end

  let ps = s:current_projects()
  call extend(g:projects, ps)

  let dict = {}
  for l in g:projects
    let dict[l] = ''
  endfor

  let g:projects = keys(dict)
  return g:projects
endfunction

function! s:current_projects() abort
  return filter(keys(b:projectionist), 'v:val !~? "^fugitive:.*"')
endfunction

function! s:up_project() abort
  let cwd = getcwd()
  let projects = reverse(s:current_projects())
  let i = index(projects, cwd)
  if i ==# -1 || len(projects) == i + 1
    if len(projects) == 0
      let path = fnamemodify(getcwd(), ':p:h')
    else
      let path = fnamemodify(projects[0], ':p:h')
    end
  else
    let path = projects[i + 1]
  endif

  call ChangeCWDTo(expand(path))
endfunction

let s:filename = (exists($XDG_CACHE_HOME) ? $XDG_CACHE_HOME : '~/.cache' ). '/jiz4oh/vim-projects'
call mkdir(fnamemodify(expand(s:filename), ':p:h'), 'p')

function! s:load_projects() abort
  if filereadable(expand(s:filename))
    let g:projects = readfile(expand(s:filename))
  end
endfunction

function! s:save_projects() abort
  let projects = g:projects[:100]
  call writefile(filter(projects, 'isdirectory(v:val)'), expand(s:filename))
endfunction

augroup projectionist-augroup
  autocmd!

  autocmd VimEnter * call s:load_projects()
  autocmd VimLeave * call s:save_projects()
  autocmd User ProjectionistActivate call s:activate()
augroup END
