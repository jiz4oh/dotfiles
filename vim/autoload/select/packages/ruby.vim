let s:delimiter = has('win32') ? ';' : ':'

function! s:format(path) abort
  return split(a:path, '/')[-1]
endfunction

function! select#packages#ruby#prompt() abort
  return "Gem"
endfunction

function! select#packages#ruby#packages() abort
  if exists('*bundler#project') && !empty(bundler#project())
    return bundler#project().paths()
  endif

  let gem_paths = []
  let res = {}
  if exists('$GEM_PATH')
    let gem_paths = split($GEM_PATH, s:delimiter)
  else
    let gem_paths = split(systemlist('gem env path')[0], s:delimiter)
    if v:shell_error != 0
      echoerr v:shell_error
      return res
    end
  endif

  let dirs = filter(map(gem_paths,
        \ 'fnamemodify(v:val . "/gems", ":p")'),
        \ 'isdirectory(v:val)')

  let gems = flatten(map(dirs,
        \ { i, v -> map(readdir(v), { j, v2 -> v . v2})}))
  for v in gems
    let res[s:format(v)] = v
  endfor

  return res
endfunction

