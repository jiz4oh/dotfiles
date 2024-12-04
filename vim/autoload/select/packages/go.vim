function! s:match(dir) abort
  return a:dir =~? '\w\+@v\d\+\.\d\+\.\d\+'
endfunction

function! s:readdir(dir)
    return map(readdir(a:dir),
    \ {_, x -> (isdirectory(a:dir .. '/' .. x) && !s:match(x)) ?
    \          s:readdir(a:dir .. '/' .. x) : 
    \          isdirectory(a:dir .. '/' .. x) ?  a:dir .. '/' .. x : a:dir})
endfunction

function! select#packages#go#prompt() abort
  return 'Pkg'
endfunction

function! select#packages#go#packages() abort
  if exists('*go#path#Default')
    let gopath = go#path#Default()
  elseif empty($GOPATH)
    let gopath = substitute(personal#go#env('GOPATH'), '\n', '', 'g')
    let $GOPATH = gopath
  else
    let gopath = $GOPATH
  endif

  let res = {}
  let builtin = fnamemodify(gopath, ':h') . '/go/src'
  let dirs = [gopath . '/pkg/mod', builtin]
  call filter(uniq(map(dirs, 'fnamemodify(v:val, ":p")')), 'isdirectory(v:val)')
  for dir in dirs
    for x in readdir(dir[:-2], { n -> n !=# 'cache' && isdirectory(dir[:-2] .. '/' .. n)})
      let mods = flatten(s:readdir(dir[:-2] .. '/' .. x))
      for y in mods
        let name = substitute(y, dir, '', '')
        let res[name] = y
      endfor
    endfor
  endfor

  return res
endfunction
