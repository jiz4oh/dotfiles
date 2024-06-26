let g:projectionist_transformations = {}
let g:projectionist_heuristics = {
      \ ".git/": {
      \   ".git/hooks/*": {"type": "githook"},
      \   ".github/workflows/*": {"type": "githubworkflow"}
      \ },
      \ ".hg/|.svn/|.bzr/|Makefile": {
      \ },
      \ "package-lock.json": {
      \   "*": {
      \      "make": "npm",
      \   },
      \   "yarn.lock": {
      \      "make": "yarn",
      \   },
      \ },
      \ "yarn.lock": {
      \   "*": {
      \      "make": "yarn",
      \   },
      \   "package-lock.json": {
      \      "make": "npm",
      \   },
      \ },
      \ "package.json": {
      \   "*": {
      \      "console": "node"
      \   },
      \   "package.json": {
      \      "type": "lib",
      \      "alternate": ["yarn.lock", "package-lock.json"]
      \   },
      \   "package-lock.json": {
      \      "dispatch": "npm install",
      \      "alternate": "package.json",
      \      "start": "npm run start",
      \   },
      \   "yarn.lock": {
      \      "dispatch": "yarn install",
      \      "alternate": "package.json",
      \      "start": "yarn run start",
      \   },
      \ },
      \ "Gemfile|Rakefile|*.gemspec": {
      \ },
      \ 'requirements.txt|requirements.in': {
      \   '*.py': {
      \      'make': 'python',
      \   },
      \   'requirements.txt': {
      \      'make': 'pip',
      \      'dispatch': 'pip install -r %',
      \   },
      \ },
      \ 'go.mod': {
      \   '*.go': {
      \      'make': 'go',
      \      'alternate': '{}_test.go',
      \   },
      \   '*_test.go': {
      \      'make': 'go',
      \      'alternate': '{gotest}.go',
      \   },
      \   'go.mod': {
      \      'make': 'go',
      \      'type': 'lib',
      \      'alternate': 'go.sum',
      \      'dispatch': 'go mod tidy',
      \   },
      \   'go.sum': {
      \      'make': 'go',
      \      'alternate': 'go.mod',
      \      'dispatch': 'go mod tidy',
      \   },
      \ },
      \}

function! g:projectionist_transformations.gotest(input, o) abort
  return substitute(a:input, '_test', '', 'g')
endfunction

" https://helm.sh/docs/topics/charts/
" let g:projectionist_heuristics['Chart.yaml'] = {
"       \   'templates/*.yaml': {
"       \      'make': 'helm',
"       \      'dispatch': 'helm template %:s/.*/\=projectionist#path()/',
"       \   },
"       \   'values.yaml': {
"       \      'make': 'helm',
"       \      'dispatch': 'helm template %:s/.*/\=projectionist#path()/',
"       \   },
"       \ }

let g:projects = []

function! s:activate() abort
  if exists('*repeat')
    map <silent> <Plug>UpwardProject :call <SID>up_project()<bar>silent! call repeat#set("\<Plug>UpwardProject", v:count)<cr>
    nmap <silent> <leader>cdP <Plug>UpwardProject
  else
    noremap <silent> <leader>cdP :call <SID>up_project()<cr>
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
    let path = fnamemodify(projects[0], ':p:h')
  else
    let path = projects[i + 1]
  endif

  call ChangeCWDTo(expand(path))
endfunction

augroup projectionist-augroup
  autocmd!
  autocmd User ProjectionistActivate call s:activate()
augroup END
