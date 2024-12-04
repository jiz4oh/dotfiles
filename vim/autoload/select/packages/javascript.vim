function! select#packages#javascript#prompt() abort
  return 'Module'
endfunction

function! select#packages#javascript#packages() abort
  let res = {}
  let cwd = personal#project#find_home()

  for [plugin, m] in items(s:process_module(cwd))
    let res[plugin] = m['dir']
  endfor

  return res
endfunction

function! s:process_module(dir) abort
  let res = {}
  let node_modules = a:dir . '/node_modules'
  if !isdirectory(node_modules)
    return res
  endif

  let deps = s:dependency_types(a:dir)
  for entry in readdir(node_modules)
    let full_path = node_modules . '/' . entry
    
    if entry[0] ==# '@' && isdirectory(full_path)
      for scope_entry in readdir(full_path)
        let scope_path = full_path . '/' . scope_entry
        call s:process_package(res, scope_path, deps)
      endfor
    else
      call s:process_package(res, full_path, deps)
    endif
  endfor

  return res
endfunction

function! s:process_package(results, dir, deps) abort
  let package_json = a:dir . '/package.json'
  if !filereadable(package_json)
    return
  endif

  let package_content = join(readfile(package_json), "\n")
  let package_data = json_decode(package_content)
  
  if has_key(package_data, 'name')
    let name = package_data['name']
    let level = get(a:deps, name, '')
    let a:results[name] = {
          \ 'dir': a:dir,
          \ 'level': level
          \ }
  endif
endfunction

function! s:dependency_types(dir) abort
  let package_json = a:dir . '/package.json'
  
  if !filereadable(package_json)
    return {}
  endif

  let package_content = join(readfile(package_json), "\n")
  let package_data = json_decode(package_content)
  
  let dependency_types = {
        \ 'dependencies': 'prod',
        \ 'devDependencies': 'dev',
        \ 'peerDependencies': 'peer',
        \ 'optionalDependencies': 'optional'
        \ }
  
  let deps = {}
  for [key, level] in items(dependency_types)
    if has_key(package_data, key)
      for [name, _] in items(package_data[key])
        let deps[name] = level
      endfor
    endif
  endfor

  return deps
endfunction
