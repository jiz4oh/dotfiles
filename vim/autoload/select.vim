let s:is_win = has('win32') || has('win64')

if has('nvim')
lua<<EOF
vim.ui = vim.ui or {}
vim.ui.__select_wrapper = function(list, id, prompt)
  vim.ui.select(list, {prompt = prompt}, function(item, idx)
    if item then
      vim.fn['select#call_func'](id, item, idx - 1)
    end
  end)
end
EOF
end

let s:funcs = {}
function! select#call_func(id, item, idx)
  if empty(get(s:funcs, a:id))
    return
  end

  call s:funcs[a:id](a:item, a:idx)
  call remove(s:funcs, a:id)
endfunction

function! select#input(prompt, list, func) abort
  if has('nvim-0.6')
    let id = id(a:func)
    let s:funcs[id] = a:func
    call v:lua.vim.ui.__select_wrapper(a:list, id, a:prompt)
  else
    let list = copy(a:list)
    call map(list, { i,v -> i + 1 . ':' . v})
    call insert(list, a:prompt, 0)
    let idx = inputlist(list)
    if idx > 0 && idx <= len(a:list)
      call a:func(a:list[idx - 1], idx - 1)
    end
  end
endfunction

function select#get_files(query, paths)
  if exists('*RgWithWildignore')
    let l:query = empty(a:query) ? shellescape('') : '-w ' . shellescape(a:query)
    let l:paths = join(flatten(copy(a:paths)), ' ')
    let l:grep_cmd = RgWithWildignore(l:query . ' ' . l:paths)
  else
    let l:grep_cmd = 'find '. a:paths . ' -type f'
  endif

  if has('nvim-0.5')
    lua vim.notify('searching')
  else
    echo 'searching'
  end

  let files = systemlist(l:grep_cmd)
  return files
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
  let l:paths = split(&path, ',')
  let l:paths = uniq(l:paths, {i1, i2 -> fnamemodify(expand(i1), ':p:~:.') != fnamemodify(expand(i2), ':p:~:.')})
  let l:paths = filter(l:paths, {_, v -> isdirectory(expand(v)) })
  let l:paths = map(l:paths, {_, val -> fnamemodify(expand(val), ':~:.')})
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
  if !empty(a:item) && exists('*GetSessions')
    call LoadSession(a:item)
  end
endfunction

function! select#sessions()
  let list = select#get_sessions()
  let prompt = 'Sessions> '
  call select#input(prompt, list, function('select#on_choice_session'))
endfunction

function! select#compilers()
  let list = select#get_compilers()
  let prompt = 'Compilers> '
  call select#input(prompt, list, function('select#on_choice_compiler'))
endfunction

function! select#projects()
  let list = select#get_projects()
  let prompt = personal#functions#shortpath(getcwd()) . ' '
  call select#input(prompt, list, function('select#on_choice_directory'))
endfunction

function! select#paths(query, fullscreen)
  let list = select#get_paths()
  let prompt = personal#functions#shortpath(getcwd()) . ' '
  call select#input(prompt, list, function('select#on_choice_directory'))
endfunction

function! select#grep(query, ...)
  if !executable('rg')
    if has('nvim-0.5')
      lua vim.notify({'rg is not installed', vim.log.levels.ERROR})
    else
      echoerr 'rg is not installed'
    end
    return
  end

  if empty(a:0)
    let l:paths = [getcwd()]
  else
    let l:paths = a:000
  endif

  let list = select#get_files(a:query, l:paths)
  let prompt = personal#functions#shortpath(getcwd()) . ' '
  call select#input(prompt, list, { l, _ -> fzf#helper#colon_sink(['enter',l], { 'enter': 'edit'})})
endfunction

function! select#packages(fullscreen, ...)
  let opts = {
        \ 'fullscreen': a:fullscreen,
        \}
  if !empty(a:000) && index(select#package#filetypes(), a:1) > -1
    let opts['query'] = get(a:, 2, '')
    call select#package#call(a:1, opts)
    return
  end

  let opts['query'] = get(a:, 1, '')
  try
    call select#package#call(&filetype, opts)
  catch
    let prompt = 'Select Packages of'
    let list = select#package#filetypes()
    call select#input(prompt, list, { l, _ -> select#package#call(l, opts)})
  endtry
endfunction
