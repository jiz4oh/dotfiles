call ale#Set('goctl_executable', 'goctl')

function! s:remove_tab(bufnr, output)
  if getbufvar(a:bufnr, 'expandtab')
    let l:spaces = repeat(' ', &tabstop)
    return map(a:output, {_, v -> substitute(v, '\\t', spaces, 'g')})
  else
    return a:output
  endif
endfunction

function! ale#fixers#zeroapifmt#Fix(buffer) abort
  let l:executable = ale#Var(a:buffer, 'goctl_executable')

  return {
  \   'command': ale#Escape(l:executable)
  \       . ' api format --stdin ',
  \   'process_with': function('s:remove_tab'),
  \}
endfunction
