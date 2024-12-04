let s:packages = {}

function! s:package_content_search(package, query, fullscreen) abort
  let dir = s:packages[a:package]
  if exists('*RgWithWildignore')
    let l:grep_cmd = RgWithWildignore('--color=always ' .fzf#shellescape(a:query))
  else
    let l:grep_cmd = 'find '. dir . ''
  endif

  let l:spec = {
        \'dir': dir,
        \'options': [
          \'--prompt', a:package.'> '
        \]}

  if !empty(a:query)
    call add(l:spec['options'], '--header')
    call add(l:spec['options'], a:query)
  endif

  call fzf#vim#grep(l:grep_cmd, fzf#vim#with_preview(l:spec), a:fullscreen)
endfunction

" package search
function! s:package_search(prompt, packages, query, fullscreen) abort
  let s:packages = a:packages

  try
    let action = get(g:, 'fzf_action')
    let g:fzf_action = {
      \ 'enter':  {package -> s:package_content_search(package[0], a:query, a:fullscreen)},
      \ 'ctrl-l':  {_ -> select#package#register(a:prompt, a:packages, a:query, a:fullscreen) },
      \}
    let l:spec = {
                  \'options': [
                    \'--prompt', a:prompt. '> ',
                  \],
                  \'source': keys(s:packages),
                  \}

    if !empty(a:query)
      call add(l:spec['options'], '--header')
      call add(l:spec['options'], a:query)
    endif

    call fzf#run(fzf#wrap('packages', l:spec, a:fullscreen))
  finally
    if exists('action') && type(action) != type(0)
      let g:fzf_action = action
    else
      unlet! g:fzf_action
    endif
  endtry
endfunction

" packages search
function! select#package#register(prompt, packages, query, fullscreen) abort
  let l:package_paths = values(a:packages)

  if exists('*RgWithWildignore')
    let l:query = empty(a:query) ? fzf#shellescape('') : '-w ' . fzf#shellescape(a:query)
    let l:grep_cmd = RgWithWildignore('--color=always ' .l:query . ' ' . join(l:package_paths, ' '))
  else
    let l:grep_cmd = 'find '. join(l:package_paths, ' ') . ' -type f'
  endif

  let l:actions = {
    \ 'ctrl-l':  {_ -> s:package_search(a:prompt, a:packages, a:query, a:fullscreen) },
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
                  \'--prompt', a:prompt. '> ',
                  \'--multi', '--bind', 'alt-a:select-all,alt-d:deselect-all',
                  \'--delimiter', ':', '--preview-window', '+{2}-/2'
                \]}

  if !empty(a:query)
    call add(l:spec['options'], '--header')
    call add(l:spec['options'], a:query)
  endif

  try
    let prev_default_command = $FZF_DEFAULT_COMMAND
    let $FZF_DEFAULT_COMMAND = l:grep_cmd
    call fzf#run(fzf#wrap(fzf#vim#with_preview(l:spec), a:fullscreen))
  finally
    let $FZF_DEFAULT_COMMAND = prev_default_command
  endtry
endfunction

function! select#package#call(filetype, query, fullscreen)
  let packages = function('select#packages#'.a:filetype.'#packages')()
  let prompt = function('select#packages#'.a:filetype.'#prompt')()

  call select#package#register(prompt, packages, a:query, a:fullscreen)
endfunction

function! select#package#filetypes()
  return [
        \'ruby',
        \'go',
        \'vim',
        \]
endfunction
