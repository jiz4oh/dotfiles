let g:projectionist_transformations = {}

"https://gist.github.com/jiz4oh/d763f906c65e302b0162a3c05723138b
let g:projectionist_heuristics = {
      \ ".git/": {
      \   ".git/hooks/*": {"type": "githook"},
      \   ".github/workflows/*": {"type": "githubworkflow"}
      \ },
      \ ".hg/|.svn/|.bzr/": {
      \ },
      \}

function! g:projectionist_transformations.gotest(input, o) abort
  return substitute(a:input, '_test', '', 'g')
endfunction

let g:projects = []

function! s:activate() abort
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
