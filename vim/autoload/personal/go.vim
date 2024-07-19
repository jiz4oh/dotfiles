function! personal#go#module() abort
  let l:module = split(personal#go#env('GOMOD'), '\n', 1)[0]

  " When run with `GO111MODULE=on and not in a module directory, the module will be reported as /dev/null.
  let l:fakeModule = '/dev/null'
  if get(g:, 'is_win')
    let l:fakeModule = 'NUL'
  endif

  if l:fakeModule == l:module
    return
  endif

  return resolve(fnamemodify(l:module, ':p:h'))
endfunction

function! personal#go#env(env) abort
  let l:wd = getcwd()
  let l:dir = personal#functions#chdir(l:wd)
  try
    let l:out = system(['go', 'env', a:env])
    if v:shell_error != 0
      return
    endif
  finally
    call personal#functions#chdir(l:dir)
  endtry

  return l:out
endfunction
