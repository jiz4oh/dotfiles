let s:cpo_save = &cpo
set cpo&vim

autocmd BufNewFile,BufRead *.api call <SID>zeroapi()

fun! s:zeroapi()
  for l:i in range(1, line('$'))
    let l:l = getline(l:i)
    if l:l ==# '' || l:l[:1] ==# '//'
      continue
    endif

    if l:l =~# '^syntax .\+'
      setfiletype zeroapi
    endif

    break
  endfor
endfun

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
