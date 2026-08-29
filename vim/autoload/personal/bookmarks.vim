let s:lock_timeout = 1.0
let s:stale_lock_age = 5

let s:default_bookmarks = [
            \ $MYVIMRC,
            \ "$HOME/.local/share/chezmoi/",
            \ "$HOME/.Trash",
            \ "$HOME/Library/Mobile Documents/com~apple~CloudDocs",
            \ ]

function! s:bookmark_file() abort
  return expand('~/.cache/startify_bookmarks')
endfunction

function! s:unique(items) abort
  let result = []
  for item in a:items
    if !empty(item) && s:index_by_path(result, item) == -1
      call add(result, item)
    endif
  endfor
  return result
endfunction

function! s:path_key(path) abort
  return fnamemodify(expand(a:path), ':p')
endfunction

function! s:short_path(path) abort
  let shortest = a:path
  for candidate in [fnamemodify(a:path, ':~')]
    if strdisplaywidth(candidate) < strdisplaywidth(shortest)
      let shortest = candidate
    endif
  endfor
  return shortest
endfunction

function! s:index_by_path(bookmarks, target) abort
  let target = s:path_key(a:target)
  let index = 0
  for bookmark in a:bookmarks
    if s:path_key(bookmark) ==# target
      return index
    endif
    let index += 1
  endfor
  return -1
endfunction

function! s:read() abort
  let file = s:bookmark_file()
  return filereadable(file)
        \ ? s:unique(map(readfile(file), 's:path_key(v:val)'))
        \ : []
endfunction

function! s:create_lock(lock) abort
  try
    return mkdir(a:lock)
  catch /^Vim\%((\a\+)\)\=:E739/
    return 0
  endtry
endfunction

function! s:acquire_lock() abort
  let lock = s:bookmark_file() . '.lock'
  silent! call mkdir(fnamemodify(lock, ':h'), 'p')
  let started = reltime()

  while !s:create_lock(lock)
    if isdirectory(lock) && localtime() - getftime(lock) >= s:stale_lock_age
      call delete(lock, 'd')
      continue
    endif
    if reltimefloat(reltime(started)) >= s:lock_timeout
      throw 'bookmarks: timed out waiting for ' . lock
    endif
    sleep 10m
  endwhile

  return lock
endfunction

function! s:write(items) abort
  let file = s:bookmark_file()
  let suffix = substitute(reltimestr(reltime()), '[^0-9]', '', 'g')
  let temporary = printf('%s.tmp.%d.%s', file, getpid(), suffix)

  try
    if writefile(a:items, temporary) == -1
      throw 'bookmarks: failed to write ' . temporary
    endif
    if rename(temporary, file) != 0
      throw 'bookmarks: failed to replace ' . file
    endif
  finally
    call delete(temporary)
  endtry
endfunction

function! s:update(action, bookmark) abort
  let lock = s:acquire_lock()
  try
    let bookmarks = s:read()
    let index = s:index_by_path(bookmarks, a:bookmark)
    if a:action ==# 'add' && index == -1
      call add(bookmarks, a:bookmark)
      call s:write(bookmarks)
    elseif a:action ==# 'delete' && index != -1
      call remove(bookmarks, index)
      call s:write(bookmarks)
    endif
    return bookmarks
  finally
    call delete(lock, 'd')
  endtry
endfunction

function! personal#bookmarks#list() abort
  let entries = []
  for bookmark in s:unique(copy(s:default_bookmarks) + s:read())
    let path = s:path_key(bookmark)
    call add(entries, {
          \ 'line': s:short_path(path),
          \ 'path': fnameescape(path),
          \ 'type': 'file',
          \ 'cmd': 'edit',
          \ })
  endfor
  return entries
endfunction

function! personal#bookmarks#add(bookmark) abort
  let bookmark = empty(a:bookmark) ? expand('%:p') : a:bookmark
  if empty(bookmark)
    echoerr 'BookmarkAdd: no bookmark path'
    return
  endif
  let bookmark = s:path_key(bookmark)
  if s:index_by_path(s:default_bookmarks, bookmark) != -1
    return
  endif
  call s:update('add', bookmark)
endfunction

function! personal#bookmarks#del(bookmark, idx) abort
  call s:update('delete', a:bookmark)
endfunction

function! personal#bookmarks#delete() abort
  let bookmarks = s:read()
  if empty(bookmarks)
    echo 'No user bookmarks'
    return
  endif
  call select#input(
        \ 'Delete bookmark> ',
        \ bookmarks,
        \ function('personal#bookmarks#del')
        \ )
endfunction

function! personal#bookmarks#edit() abort
  exe 'edit '. s:bookmark_file()
endfunction
