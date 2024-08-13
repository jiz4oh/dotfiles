function! select#get_compilers() abort
  let compilers = split(globpath(&runtimepath, 'compiler/*.vim'), '\n')
  if has('packages')
    let compilers += split(globpath(&packpath, 'pack/*/opt/*/compiler/*.vim'), '\n')
  endif
  return fzf#vim#_uniq(map(compilers, "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')"))
endfunction

function! select#get_paths() abort
  let l:slash = (g:is_win && !&shellslash) ? '\\' : '/'
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

function! select#compilers()
  if has('nvim-0.6')
lua<<EOF
  vim.ui.select(vim.fn['select#get_compilers'](), {prompt = 'Compilers> '}, function(item, idx)
    if item == nil then
      return
    end

    vim.cmd('compiler ' .. item)
  end)
EOF
  return
end

  if exists('*fzf#customized#compilers')
    call fzf#customized#compilers()
    return
  end
endfunction

function! select#projects()
  if has('nvim-0.6')
lua<<EOF
  vim.ui.select(vim.fn['select#get_projects'](), {prompt = vim.fn['personal#functions#shortpath'](vim.fn.getcwd()) ..' '}, function(item, idx)
    if item == nil then
      return
    end

    vim.cmd('NERDTree ' .. item)
  end)
EOF
  return
end

  if exists('*fzf#customized#projects')
    call fzf#customized#projects()
    return
  end
endfunction

function! select#paths(query, fullscreen)
  if has('nvim-0.6')
lua<<EOF
  vim.ui.select(vim.fn['select#get_paths'](), {prompt = vim.fn['personal#functions#shortpath'](vim.fn.getcwd()) ..' '}, function(item, idx)
    if item == nil then
      return
    end

    vim.cmd('NERDTree ' .. item)
  end)
EOF
  return
end

  if exists('*fzf#customized#path')
    call fzf#customized#path(a:query, a:fullscreen)
    return
  end
endfunction
