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
  set operatorfunc={range\ ->\ personal#op#exec(range,a:command)}
  return 'g@'
endfunction

function! personal#op#map(lhs, cmd) abort
  execute 'nmap <expr> ' . a:lhs . " personal#op#build(" . string(a:cmd) .")"
  execute 'xmap <expr> ' . a:lhs . " personal#op#build(" . string(a:cmd) .")"
  execute 'omap <expr> ' . a:lhs . " personal#op#build(" . string(a:cmd) .")"
endfunction
