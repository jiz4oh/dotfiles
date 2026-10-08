let g:flog_default_opts = { 'date': 'iso-local' }

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
  let b:start = ':Floggit' . (exists('*setbufline') && !exists('$SSH_CLIENT') ? '!' : '') . ' push'
  execute "nnoremap <buffer> '<Space> " . b:start . '<Space>'
  nnoremap <silent> <buffer> cbt :execute 'Floggit branch --set-upstream-to=origin/' . FugitiveHead()<CR>
  nnoremap <buffer> cmf :Floggit merge -X theirs<Space>
  nnoremap <buffer> cp  :Floggit cherry-pick<Space>
  nnoremap <buffer> cbd :Floggit branch -d<Space>
  nnoremap <buffer> cbD :Floggit branch -D<Space>

  nmap <buffer> cn <Plug>(FlogSquashEdit)
  nmap <buffer> cA <Plug>(FlogSquashEdit)
  nnoremap <silent> <buffer> cw  :<C-U>Floggit commit --amend --only<CR>
  nnoremap <silent> <buffer> cvc :<C-U>tab Floggit commit -v<CR>
  nnoremap <silent> <buffer> cva :<C-U>tab Floggit commit -v --amend<CR>

  nnoremap <buffer> cz<Space> :Floggit stash<Space>
  nnoremap <buffer> cz<CR> :Floggit stash<CR>
  nnoremap <buffer> cza :<C-U>Floggit stash apply --quiet --index stash@{<C-R>=v:count<CR>}<CR>
  nnoremap <buffer> czA :<C-U>Floggit stash apply --quiet stash@{<C-R>=v:count<CR>}<CR>
  nnoremap <buffer> czp :<C-U>Floggit stash pop --quiet --index stash@{<C-R>=v:count<CR>}<CR>
  nnoremap <buffer> czP :<C-U>Floggit stash pop --quiet stash@{<C-R>=v:count<CR>}<CR>
  nnoremap <buffer> czs :<C-U>Floggit stash push --staged<CR>
  nnoremap <silent> <buffer> czv :<C-U>call flog#Exec('Gedit ' . fugitive#RevParse('stash@{' . v:count . '}'))<CR>
  nnoremap <buffer> czw :<C-U>Floggit stash push --keep-index<C-R>=v:count > 1 ? ' --all' : v:count ? ' --include-untracked' : ''<CR><CR>
  nnoremap <buffer> czz :<C-U>Floggit stash push <C-R>=v:count > 1 ? ' --all' : v:count ? ' --include-untracked' : ''<CR><CR>
  nnoremap <silent> <buffer> cz? :help fugitive_cz<CR>

  nnoremap <silent> <buffer> o   :execute flog#Format('vertical Floggit -s -t show --remerge-diff %h')<CR>
  nnoremap <silent> <buffer> cr1 :execute flog#Format('Floggit revert -m 1 %h')<cr>
  nnoremap <silent> <buffer> cr2 :execute flog#Format('Floggit revert -m 2 %h')<cr>
  nnoremap <expr>   <buffer> X   <SID>reset(<SID>hashes('.', 1))
endfunction
