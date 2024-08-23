if get(s:, 'loaded', 0) != 0
	finish
endif
let s:loaded = 1

command! -nargs=? -bang Compilers             call select#compilers()
command! -nargs=? -bang Sessions              call select#sessions()
command! -nargs=? -bang Projects              call select#projects()
command! -nargs=? -bang Path                  call select#paths(<q-args>, <bang>0)
