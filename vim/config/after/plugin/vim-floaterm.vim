function!  s:escape(str) abort
  let str = substitute(a:str, '\\', '\\\\', 'g')
  let str = substitute(str, ' ', '\\ ', 'g')
  return str
endfunction

function! s:start() abort
  let cmd = '--name=start'
  let name = 'start'
  if !empty(get(b:, 'start', ''))
    let [cmdd, opts] = personal#functions#parse_start(b:start)
    if cmdd =~# '^:'
      botright Start
      return 
    endif
    let name = cmdd
    if !empty(get(opts, 'directory'))
      let name .= opts.directory
      let cmd .= ' --cwd=' . s:escape(opts.directory)
    endif
    if !empty(get(opts, 'title'))
      let name .= opts.title
      let cmd .= ' --title=' . s:escape(opts.title) . '\ ($1/$2)'
    endif
    let cmd .= ' --name='. s:escape(name)
    let cmd .= ' ' . cmdd
  end

  let bufnr = floaterm#terminal#get_bufnr(name)
  if bufnr == -1
    execute 'FloatermNew ' . cmd
  else
    execute 'FloatermShow ' . name
  end
endfunction

nmap <silent> '<CR> :call <SID>start()<CR>
