" returns nearest parent directory contains one of the markers
function! personal#project#find_root()
  let l:dir = ''
  if exists('*projectionist#path')
    let l:dir = get(l:, 'dir', projectionist#path())
  endif
  if exists('*FindRootDirectory')
    let l:dir = get(l:, 'dir', FindRootDirectory())
  endif

  let parent = substitute(expand('%:p:h'), 'oil://', '', '')
  if has('nvim-0.10') && exists('g:project_markers')
    return v:lua.vim.fs.root(parent, g:project_markers)
  end

  if empty(l:dir)
    let l:git_root = system('cd ' . parent . ' && git rev-parse --show-toplevel 2>/dev/null')[:-2]
    if v:shell_error == 0
      let l:dir = l:git_root
    endif
  end

  return l:dir
endfunction

" returns nearest parent directory contains one of the markers
function! personal#project#find_home()
  let dir = personal#project#find_root()
  " fallback to the directory containing the file
  if empty(dir)
    let dir = expand('%:p:h')
  endif
  " or the user's home directory
  if empty(dir)
    let dir = expand('~')
  endif
  return dir
endfunction
