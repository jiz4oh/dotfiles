let s:is_win = has('win32') || has('win64')

function! s:input(prompt, list, func) abort
  let list = copy(a:list)
  call map(list, { i,v -> i + 1 . ':' . v})
  call insert(list, a:prompt, 0)
  let idx = inputlist(list)
  if idx > 0 && idx <= len(a:list)
    call a:func(a:list[idx - 1], idx - 1)
  end
endfunction

function! select#get_compilers() abort
  let compilers = split(globpath(&runtimepath, 'compiler/*.vim'), '\n')
  if has('packages')
    let compilers += split(globpath(&packpath, 'pack/*/opt/*/compiler/*.vim'), '\n')
  endif
  return uniq(map(compilers, "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')"))
endfunction

function! select#get_paths() abort
  let l:slash = (s:is_win && !&shellslash) ? '\\' : '/'
  let l:paths = map(split(&path, ','), {_, val -> fnamemodify(expand(val), ':~:.')})
  let l:paths = uniq(sort(sort(l:paths), {i1, i2 -> len(split(i1, l:slash)) - len(split(i2, l:slash))}))
  let l:paths = filter(l:paths, {_, v -> isdirectory(fnamemodify(v, ':p')) })
  return l:paths
endfunction

function! select#get_projects() abort
  return get(g:, 'projects', [])
endfunction

function! select#get_sessions() abort
  if !exists('*GetSessions')
    return []
  endif
  return GetSessions()
endfunction

function! select#on_choice_compiler(item, idx)
  if !empty(a:item)
    execute 'compiler' a:item
  end
endfunction

function! select#on_choice_directory(item, idx)
  if !empty(a:item)
    execute 'cd' a:item
  end
endfunction

function! select#on_choice_session(item, idx)
  if !empty(a:item)
    call LoadSessionFromFzf(a:item)
  end
endfunction

function! select#sessions()
  if has('nvim-0.6')
lua<<EOF
  vim.ui.select(vim.fn['select#get_sessions'](), {prompt = 'Sessions> '}, vim.fn['select#on_choice_session'])
EOF
    return
  end

  let list = select#get_sessions()
  let prompt = 'Sessions> '
  call s:input(prompt, list, function('select#on_choice_session'))
endfunction

function! select#compilers()
  if has('nvim-0.6')
lua<<EOF
  vim.ui.select(vim.fn['select#get_compilers'](), {prompt = vim.fn['personal#functions#shortpath'](vim.fn.getcwd()) ..' '}, vim.fn['select#on_choice_compiler'])
EOF
    return
  end

  let list = select#get_compilers()
  let prompt = 'Compilers> '
  call s:input(prompt, list, function('select#on_choice_compiler'))
endfunction

function! select#projects()
  if has('nvim-0.6')
lua<<EOF
  vim.ui.select(vim.fn['select#get_projects'](), {prompt = vim.fn['personal#functions#shortpath'](vim.fn.getcwd()) ..' '}, vim.fn['select#on_choice_directory'])
EOF
    return
  end

  let list = select#get_projects()
  let prompt = personal#functions#shortpath(getcwd()) . ' '
  call s:input(prompt, list, function('select#on_choice_directory'))
endfunction

function! select#paths(query, fullscreen)
  if has('nvim-0.6')
lua<<EOF
  vim.ui.select(vim.fn['select#get_paths'](), {prompt = vim.fn['personal#functions#shortpath'](vim.fn.getcwd()) ..' '}, vim.fn['select#on_choice_directory'])
EOF
    return
  end

  let list = select#get_paths()
  let prompt = personal#functions#shortpath(getcwd()) . ' '
  call s:input(prompt, list, function('select#on_choice_directory'))
endfunction
