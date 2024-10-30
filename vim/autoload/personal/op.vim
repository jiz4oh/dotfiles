function! s:range(type) abort
  return get({
        \ 'line': "'[,']",
        \ 'char': '0,1',
        \ 'block': line('$') < 2 ? '0,1' : '0,2',
        \ 'V': "'<,'>",
        \ 'v': '0',
        \ "\<C-V>": '0',
        \ 0: '%',
        \ 1: '.'},
        \ a:type, '.,.+' . (a:type-1))
endfunction

function! personal#op#exec(...) abort
  exe s:range(a:1) . a:2
endfunction

function! personal#op#build(command) abort
  exec printf('setlocal operatorfunc={range->personal#op#exec(range,%s)}', string(a:command))
  return 'g@'
endfunction

function! personal#op#map(lhs, cmd) abort
  let l:modes = ['n', 'x', 'o']
  for l:mode in l:modes
    execute printf('%smap <expr> %s personal#op#build(%s)', l:mode, a:lhs, escape(string(a:cmd), '"'))
  endfor
endfunction
