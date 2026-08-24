let s:rails_engine_path_dirs = [
      \ 'app/models/concerns',
      \ 'app/controllers/concerns',
      \ 'app/controllers',
      \ 'app/helpers',
      \ 'app/mailers',
      \ 'app/models',
      \ 'app/jobs',
      \ 'app/serializers',
      \ 'app/decorators',
      \ 'app/overrides',
      \ 'app/services',
      \ 'app/policies',
      \ 'app/validators',
      \ 'app/uploaders',
      \ 'app/*',
      \ ]
let s:rails_engine_paths_cache = {}

function! s:uniq(paths) abort
  let seen = {}
  let result = []
  for path in a:paths
    if empty(path) || has_key(seen, path)
      continue
    endif
    let seen[path] = 1
    call add(result, path)
  endfor
  return result
endfunction

function! s:bundler_gem_roots(project) abort
  if has_key(a:project, 'sorted')
    return a:project.sorted()
  endif
  if has_key(a:project, 'paths')
    return sort(values(a:project.paths()))
  endif
  return []
endfunction

function! s:rails_engine_roots(root) abort
  let roots = []
  if isdirectory(a:root . '/app')
    call add(roots, a:root)
  endif

  for gemspec in glob(a:root . '/*/*.gemspec', 0, 1)
    let root = fnamemodify(gemspec, ':h')
    if isdirectory(root . '/app')
      call add(roots, root)
    endif
  endfor

  return s:uniq(roots)
endfunction

function! s:rails_engine_paths(project) abort
  let gem_roots = s:bundler_gem_roots(a:project)
  let key = join(gem_roots, "\n")
  if has_key(s:rails_engine_paths_cache, key)
    return copy(s:rails_engine_paths_cache[key])
  endif
  if len(s:rails_engine_paths_cache) > 128
    let s:rails_engine_paths_cache = {}
  endif

  let paths = []
  for gem_root in gem_roots
    for engine_root in s:rails_engine_roots(gem_root)
      for dir in s:rails_engine_path_dirs
        if dir =~# '\*$'
          if isdirectory(engine_root . '/' . substitute(dir, '/\*$', '', ''))
            call add(paths, engine_root . '/' . dir)
          endif
        elseif isdirectory(engine_root . '/' . dir)
          call add(paths, engine_root . '/' . dir)
        endif
      endfor
    endfor
  endfor
  let paths = s:uniq(paths)
  let s:rails_engine_paths_cache[key] = paths
  return copy(paths)
endfunction

function! s:append_paths(paths) abort
  if empty(a:paths)
    return
  endif

  let tail = matchstr(&l:path, '\%(,\.\)\=\%(,,\)\=$')
  let value = strpart(&l:path, 0, len(&l:path) - len(tail))
  let current = empty(value) ? [] : split(value, ',')
  let seen = {}
  for path in current
    let seen[path] = 1
  endfor

  let additions = []
  for path in a:paths
    let escaped = escape(path, ', ')
    if !has_key(seen, escaped)
      let seen[escaped] = 1
      call add(additions, escaped)
    endif
  endfor

  if !empty(additions)
    let &l:path = join(current + additions, ',') . tail
  endif
endfunction

function! s:add_rails_engine_paths(project) abort
  call s:append_paths(s:rails_engine_paths(a:project))
endfunction

function! s:init_ruby()
  call MyLoad('vim-bundler')
  let project = bundler#project()
  if !empty(project)
    call s:add_rails_engine_paths(project)

    if project.has('solargraph')
      let b:ale_ruby_solargraph_executable = 'bundle exec solargraph'
    endif

    if project.has('rubocop')
      let b:ale_ruby_rubocop_executable = 'bundle'
    endif
  endif
endfunction

augroup vim-bundler-augroup
  autocmd!

  autocmd! FileType ruby,eruby call s:init_ruby()
augroup END
