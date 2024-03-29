let s:default_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'
  \}

function! s:split_grep(line)
  let parts = matchlist(a:line, '\(.\{-}\)\s*:\s*\(\d\+\)\%(\s*:\s*\(\d\+\)\)\?\%(\s*:\(.*\)\)\?')
  let dict = {'filename': &autochdir ? fnamemodify(parts[1], ':p') : parts[1], 'lnum': parts[2], 'text': parts[4]}
  if len(parts[3])
    let dict.col = parts[3]
  endif
  return dict
endfunction

function! s:open(cmd, target)
  if stridx('edit', a:cmd) == 0 && fnamemodify(a:target, ':p') ==# expand('%:p')
    normal! m'
    return
  endif
  execute a:cmd personal#functions#escape(a:target)
endfunction

function! s:fill_quickfix(list, ...)
  if len(a:list) > 1
    call setqflist(a:list)
    copen
    wincmd p
    if a:0
      execute a:1
    endif
  endif
endfunction

" key (strint), [default (string)]
function! s:action_for(key, ...)
  let default = a:0 ? a:1 : ''
  let Cmd = get(get(g:, 'fzf_action', s:default_action), a:key, default)
  return type(Cmd) == type('') ? Cmd : default
endfunction

" lines (array), [actions (dict)]
" extend fzf butil-in ag_handler
" actions can be used with function which first parameter is {'filename': '', 'lnum': '', 'text': '', col: ''}
function! fzf#helper#colon_sink(lines, ...)
  let key = a:lines[0]
  if a:0
    let Cmd = get(a:1, key, 'e')
  else
    let Cmd = s:action_for(key, 'e')
  end

  let list = map(filter(a:lines[1:], 'len(v:val)'), 's:split_grep(v:val)')
  if empty(list)
    return
  endif

  let first = list[0]
  try
    if type(Cmd) == type(function('call'))
      return Cmd(list)
    end

    call s:open(Cmd, first.filename)
    execute first.lnum
    if has_key(first, 'col')
      call cursor(0, first.col)
    endif
    normal! zvzz
  catch
  endtry

  call s:fill_quickfix(list)
endfunction

function! s:_reserve_cmd(func)
  try
    let prev_default_command = $FZF_DEFAULT_COMMAND
    call a:func()
  finally
    let $FZF_DEFAULT_COMMAND = prev_default_command
  endtry
endfunction

function! fzf#helper#reserve_cmd(func) abort
  return function('s:_reserve_cmd', [a:func])
endfunction

function! fzf#helper#reserve_action(func) abort
  let container = {}

  function! container.func() closure dict
    try
      let action = get(g:, 'fzf_action')
      call a:func()
    finally
      if exists('action') && type(action) != type(0)
        let g:fzf_action = action
      else
        unlet! g:fzf_action
      endif
    endtry
  endfunction

  return container.func
endfunction
