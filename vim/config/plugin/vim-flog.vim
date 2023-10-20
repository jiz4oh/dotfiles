vnoremap <silent> <leader>gl :Flog<cr>
nnoremap <silent> <leader>gl :Flog -path=%<cr>
nnoremap <silent> <leader>gL :Flog<cr>

augroup flog_vim
  autocmd!
  autocmd FileType floggraph call s:init()
augroup END

function! s:hashes(line = '.', count = 1) abort
  let l:state = flog#state#GetBufState()

  if a:count < 1
    return
  endif

  let l:commit = flog#floggraph#commit#GetAtLine(a:line)
  if empty(l:commit)
    return
  endif

  let l:commit_index = index(l:state.commits, l:commit)

  let l:hashes = [l:commit.hash]
  let l:i = 1
  while l:i < a:count
    let l:commit = get(l:state.commits, l:commit_index + l:i, {})
    if empty(l:commit)
      break
    endif

    call add(l:hashes, l:commit.hash)

    let l:i += 1
  endwhile

  return l:hashes
endfunction

function! s:hashes(line = '.', count = 1) abort
  let l:state = flog#state#GetBufState()

  if a:count < 1
    return []
  endif

  let l:commit = flog#floggraph#commit#GetAtLine(a:line)
  if empty(l:commit)
    return []
  endif

  let l:commit_index = index(l:state.commits, l:commit)

  let l:hashes = [l:commit.hash]
  let l:i = 1
  while l:i < a:count
    let l:commit = get(l:state.commits, l:commit_index + l:i, {})
    if empty(l:commit)
      break
    endif

    call add(l:hashes, l:commit.hash)

    let l:i += 1
  endwhile

  return l:hashes
endfunction

function! s:hashesRange(start_line = "'<", end_line = "'>") abort
  let l:state = flog#state#GetBufState()

  let l:start_commit = flog#floggraph#commit#GetAtLine(a:start_line)
  let l:end_commit = flog#floggraph#commit#GetAtLine(a:end_line)
  if empty(l:start_commit) || empty(l:end_commit)
    return []
  endif

  let l:start_index = index(l:state.commits, l:start_commit)
  let l:end_index = index(l:state.commits, l:end_commit)
  if l:start_index < 0 || l:end_index < 0
    return []
  endif

  return s:hashes(a:start_line, l:end_index - l:start_index + 1)
endfunction

function! s:reset(hashes)
  if empty(a:hashes)
    return
  endif

  return ":Floggit reset " . a:hashes[-1] . "^"
endfunction

function! s:init() abort
  nnoremap <silent> <buffer> o   :vertical Flogsplitcommit<cr>
  nnoremap <silent> <buffer> cr1 :execute flog#Format('Floggit revert -m 1 %h')<cr>
  nnoremap <silent> <buffer> cr2 :execute flog#Format('Floggit revert -m 2 %h')<cr>
  nnoremap <expr>   <buffer> X   <SID>reset(<SID>hashes('.', 1))
endfunction
