" `brew install ripgrep` before you use rg command
if !executable('rg')
  function! fzf#customized#grep(dir, query, fullscreen) abort
    if !empty(a:query)
      let @/ = a:query
    endif
    if !empty(FugitiveGitDir())
      let l:query = fzf#shellescape(a:query)
      let l:grep_cmd = 'git grep --color=always --line-number ' . l:query . ' -- ' . a:dir

      call fzf#vim#grep(l:grep_cmd, fzf#vim#with_preview({'dir': a:dir, 'options': ['--prompt', personal#functions#shortpath(a:dir) . ' ', '--delimiter', ':', '--nth', '3..']}), a:fullscreen)
    else
      let l:grep_cmd = 'find ' . a:dir . ' -type f -iname "*' . a:query . '*"'

      call fzf#vim#grep(l:grep_cmd, fzf#vim#with_preview({'dir': a:dir, 'options': ['--prompt', personal#functions#shortpath(a:dir) . ' ']}), a:fullscreen)
    endif

  endfunction

  function! fzf#customized#rg(query, fullscreen)
    echohl WarningMsg
    echom 'ripgrep not found, please read https://github.com/BurntSushi/ripgrep#installation about how to install'
    echohl None
    return 0
  endfunction
else
  function! fzf#customized#grep(dir, query, fullscreen) abort
    if !empty(a:query)
      let @/ = a:query
    endif

    let l:dir = fnamemodify(a:dir, ':p:h')
    let l:spec = {
        \'dir': l:dir,
        \'options': [
            \'--prompt', personal#functions#shortpath(l:dir) .' ',
              \'--delimiter', ':',
            \]}

    if exists('*FzfWithWildignore')
      let l:query = empty(a:query) ? fzf#shellescape('') : '-w ' . fzf#shellescape(a:query)
      let l:grep_cmd = FzfWithWildignore(l:query)

      call add(l:spec['options'], '--nth')
      call add(l:spec['options'], '4..')
    else
      let l:grep_cmd = 'find '. l:dir . ''
    endif

    if !empty(a:query)
      call add(l:spec['options'], '--header')
      call add(l:spec['options'], a:query)
    endif

    call fzf#vim#grep(l:grep_cmd, fzf#vim#with_preview(l:spec), a:fullscreen)
  endfunction

  function! fzf#customized#rg(query, fullscreen)
    if !empty(a:query)
      let @/ = a:query
    endif
    let l:grep_cmd = FzfWithWildignore(fzf#shellescape(a:query))
    let l:reload_command = FzfWithWildignore('{q}')
    let l:spec = {
          \'options': [
             \'--prompt', personal#functions#shortpath(getcwd()) .'> ',
             \'--phony',
             \'--query', a:query,
             \'--bind', 'change:reload:'.l:reload_command
             \]}

    call fzf#vim#grep(l:grep_cmd, fzf#vim#with_preview(l:spec), a:fullscreen)
  endfunction
endif

function! fzf#customized#paths(query, fullscreen) abort
  if !empty(a:query)
    let @/ = a:query
  endif

  let l:slash = (g:is_win && !&shellslash) ? '\\' : '/'
  let l:paths = substitute(&path, ',', ' ', 'g')

  if exists('*FzfWithWildignore')
    let l:query = empty(a:query) ? fzf#shellescape('') : '-w ' . fzf#shellescape(a:query)
    let l:grep_cmd = FzfWithWildignore(l:query . ' ' . l:paths)
  else
    let l:grep_cmd = 'find '. l:paths . ' -type f'
  endif

  let container = {}
  function! container.func() closure
    let $FZF_DEFAULT_COMMAND = l:grep_cmd
    let l:actions = {
      \ 'ctrl-l':  {_ -> fzf#customized#path(a:query, a:fullscreen) },
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
                    \'--prompt', personal#functions#shortpath(l:dir) .' ',
                    \'--multi', '--bind', 'alt-a:select-all,alt-d:deselect-all',
                    \'--delimiter', ':', '--preview-window', '+{2}-/2'
                  \]}

    if !empty(a:query)
      call add(l:spec['options'], '--header')
      call add(l:spec['options'], a:query)
    endif

    call fzf#run(fzf#wrap('paths', fzf#vim#with_preview(l:spec), a:fullscreen))
  endfunction

  call fzf#helper#reserve_cmd(container.func)()
endfunction

" pick up from 'path'
function! fzf#customized#path(query, fullscreen) abort
  let l:slash = (g:is_win && !&shellslash) ? '\\' : '/'
  let l:paths = select#get_paths()

  let container = {}
  function! container.func() closure
    let g:fzf_action = {
      \ 'enter':  {dir -> fzf#customized#grep(fnamemodify(dir[0], ':p'), a:query, a:fullscreen) },
      \ 'ctrl-l':  {_ -> fzf#customized#paths(a:query, a:fullscreen) },
      \ 'ctrl-t': 'NERDTree ',
      \ 'ctrl-x': 'NERDTree ',
      \ 'ctrl-v': 'NERDTree '
      \}

    let l:dir = getcwd()
    let l:spec = {
                  \'dir': l:dir,
                  \'options': [
                    \'--prompt', personal#functions#shortpath(getcwd()) .' ',
                  \],
                  \'source': l:paths,
                  \}

    if !empty(a:query)
      call add(l:spec['options'], '--header')
      call add(l:spec['options'], a:query)
    endif

    call fzf#run(fzf#wrap(l:spec, a:fullscreen))
  endfunction

  call fzf#helper#reserve_action(container.func)()
endfunction

function! fzf#customized#quickfix(query, fullscreen) abort
  let l:qf = getqflist()
  let l:list = map(l:qf, funcref('fzf#customized#_format_qf_item'))
  if !empty(a:query)
    let @/ = a:query
  endif

  let l:actions = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit'
    \}
  let l:dir = getcwd()
  let l:spec = {
                \'dir': l:dir,
                \'sink*': { lines -> fzf#helper#colon_sink(lines, l:actions) },
                \'source': l:list,
                \'options': [
                  \'--expect', join(keys(actions), ','),
                  \'--ansi',
                  \'--prompt', 'Quickfix ',
                  \'--multi', '--bind', 'alt-a:select-all,alt-d:deselect-all',
                  \'--delimiter', ':', '--preview-window', '+{2}-/2'
                \]}

  call fzf#run(fzf#wrap('quickfix', fzf#vim#with_preview(l:spec), a:fullscreen))
endfunction

function! fzf#customized#_format_qf_item(_, val) abort
  return bufname(a:val.bufnr). ':'. a:val.lnum . ':' . a:val.col . ':'. a:val.text
endfunction
