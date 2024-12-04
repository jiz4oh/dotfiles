function! s:package_content_search(package, opts) abort
  let query = get(a:opts, 'query', '')
  let fullscreen = get(a:opts, 'fullscreen', 0)
  let packages = get(a:opts, 'packages', {})

  let dir = packages[a:package]
  if exists('*RgWithWildignore')
    let l:grep_cmd = RgWithWildignore('--color=always ' .fzf#shellescape(query))
  else
    let l:grep_cmd = 'find '. dir . ''
  endif

  let l:spec = {
        \'dir': dir,
        \'options': [
          \'--prompt', a:package.'> '
        \]}

  if !empty(query)
    call add(l:spec['options'], '--header')
    call add(l:spec['options'], query)
  endif

  call fzf#vim#grep(l:grep_cmd, fzf#vim#with_preview(l:spec), fullscreen)
endfunction

" package search
function! s:package_search(opts) abort
  let packages = get(a:opts, 'packages', {})
  let query = get(a:opts, 'query', '')
  let fullscreen = get(a:opts, 'fullscreen', 0)
  let prompt = get(a:opts, 'prompt', 0)

  try
    let action = get(g:, 'fzf_action')
    let g:fzf_action = {
      \ 'enter':  {package -> s:package_content_search(package[0], a:opts)},
      \ 'ctrl-l':  {_ -> select#provider#fzf#packages(a:opts) },
      \}
    let l:spec = {
                  \'options': [
                    \'--prompt', prompt. '> ',
                  \],
                  \'source': keys(packages),
                  \}

    if !empty(query)
      call add(l:spec['options'], '--header')
      call add(l:spec['options'], query)
    endif

    call fzf#run(fzf#wrap('packages', l:spec, fullscreen))
  finally
    if exists('action') && type(action) != type(0)
      let g:fzf_action = action
    else
      unlet! g:fzf_action
    endif
  endtry
endfunction

" packages search
function! select#provider#fzf#packages(opts) abort
  let packages = get(a:opts, 'packages', {})
  let query = get(a:opts, 'query', '')
  let fullscreen = get(a:opts, 'fullscreen', 0)
  let prompt = get(a:opts, 'prompt', 0)

  let l:package_paths = values(packages)

  if exists('*RgWithWildignore')
    let l:query = empty(query) ? fzf#shellescape('') : '-w ' . fzf#shellescape(query)
    let l:grep_cmd = RgWithWildignore('--color=always ' .l:query . ' ' . join(l:package_paths, ' '))
  else
    let l:grep_cmd = 'find '. join(l:package_paths, ' ') . ' -type f'
  endif

  let l:actions = {
    \ 'ctrl-l':  {_ -> s:package_search(a:opts) },
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit'
    \}
  let l:dir = getcwd()
  let l:spec = {
                \'dir': l:dir,
                \'sink*': { lines -> fzf#helper#colon_sink(lines, l:actions) },
                \'options': [
                  \'--expect', join(keys(actions), ','),
                  \'--ansi',
                  \'--prompt', prompt. '> ',
                  \'--multi', '--bind', 'alt-a:select-all,alt-d:deselect-all',
                  \'--delimiter', ':', '--preview-window', '+{2}-/2'
                \]}

  if !empty(query)
    call add(l:spec['options'], '--header')
    call add(l:spec['options'], query)
  endif

  try
    let prev_default_command = $FZF_DEFAULT_COMMAND
    let $FZF_DEFAULT_COMMAND = l:grep_cmd
    call fzf#run(fzf#wrap(fzf#vim#with_preview(l:spec), fullscreen))
  finally
    let $FZF_DEFAULT_COMMAND = prev_default_command
  endtry
endfunction
