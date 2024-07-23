" keep old clipboard
function! personal#functions#selected()
  let old_reg = getreg('"')
  let old_regtype = getregtype('"')
  let old_clipboard = &clipboard
  set clipboard&
  normal! ""gvy
  let selection = getreg('"')
  call setreg('"', old_reg, old_regtype)
  let &clipboard = old_clipboard
  return selection
endfunction

function! personal#functions#shortpath(path)
  let short = fnamemodify(a:path, ':~:.')
  if !has('win32unix')
    let short = pathshorten(short)
  endif

  return short
endfunction

function! personal#functions#escape(path)
  let path = fnameescape(a:path)
  return g:is_win ? escape(path, '$') : path
endfunction

function! personal#functions#escape_for_regexp(str)
  return escape(a:str, '^$.*?/\[]')
endfunction

" https://github.com/tpope/vim-dispatch/blob/00e77d90452e3c710014b26dc61ea919bc895e92/autoload/dispatch.vim#L433
function! personal#functions#parse_start(command, ...) abort
  let command = a:command
  let opts = {}
  while command =~# '^\%(-\|++\)\%(\w\+\)\%([= ]\|$\)'
    let opt = matchstr(command, '\zs\w\+')
    if command =~# '^\%(-\|++\)\w\+='
      let val = matchstr(command, '\w\+=\zs\%(\\.\|\S\)*')
    else
      let val = 1
    endif
    if opt ==# 'dir' || opt ==# 'directory'
      let opts.directory = fnamemodify(expand(val), ':p:s?[^:]\zs[\\/]$??')
    elseif index(['compiler', 'title', 'wait'], opt) >= 0
      let opts[opt] = substitute(val, '\\\(\s\)', '\1', 'g')
    endif
    let command = substitute(command, '^\%(-\|++\)\w\+\%(=\%(\\.\|\S\)*\)\=\s*', '', '')
  endwhile
  return [command, extend(opts, a:0 ? a:1 : {})]
endfunction

" stole from https://github.com/junegunn/dotfiles/blob/master/vimrc
function! s:colors(...)
  return filter(map(filter(split(globpath(&runtimepath, 'colors/*.vim'), "\n"),
        \                  'v:val !~ "^/usr/"'),
        \           'fnamemodify(v:val, ":t:r")'),
        \       '!a:0 || stridx(v:val, a:1) >= 0')
endfunction

function! personal#functions#rotate_colors()
  if !exists('s:colors')
    let s:colors = s:colors()
  endif
  let name = remove(s:colors, 0)
  call add(s:colors, name)
  execute 'colorscheme' name
  redraw
  echo name
endfunction

function! personal#functions#chdir(dir) abort
  if !exists('*chdir')
    let l:olddir = getcwd()
    let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd' : 'cd'
    execute printf('%s %s', cd, fnameescape(a:dir))
    return l:olddir
  endif
  return chdir(a:dir)
endfunction

  " https://github.com/tpope/vim-commentary/blob/f67e3e67ea516755005e6cccb178bc8439c6d402/plugin/commentary.vim#L16C1-L25C12
  function! s:strip_white_space(l,r,line) abort
    let [l, r] = [a:l, a:r]
    if l[-1:] ==# ' ' && stridx(a:line,l) == -1 && stridx(a:line,l[0:-2]) == 0
      let l = l[:-2]
    endif
    if r[0] ==# ' ' && (' ' . a:line)[-strlen(r)-1:] != r && a:line[-strlen(r):] == r[1:]
      let r = r[1:]
    endif
    return [l, r]
  endfunction

  function! personal#functions#uncomment_line(lines) abort
    let [l, r] = split(get(b:, 'commentary_format', substitute(substitute(substitute(
        \ &commentstring, '^$', '%s', ''), '\S\zs%s',' %s', '') ,'%s\ze\S', '%s ', '')), '%s', 1)
    let uncomment = 2

    for i in a:lines
      let line = matchstr(i,'\S.*\s\@<!')
      let [l, r] = <SID>strip_white_space(l,r,line)
      if len(line) && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
        return i
      endif
    endfor

    return ""
  endfunction

