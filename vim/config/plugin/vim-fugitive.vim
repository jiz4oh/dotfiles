nnoremap g<space>   :Git<space>
nmap     <leader>gg :Git<cr>gg)
nmap     <leader>eg :Git<cr>gg)
nnoremap <leader>gdd :Gdiffsplit<cr>
nnoremap <leader>gdb :DiffBranch<space>
nnoremap <leader>gb :Git blame<cr>
vnoremap <leader>gb :Git blame<cr>
nnoremap <leader>gx :GBrowse<cr>
vnoremap <leader>gx :GBrowse<cr>
nnoremap <leader>gr :Gread<cr>
nnoremap <leader>gw :Gwrite<cr>

augroup fugitive_vim
  autocmd!
  autocmd FileType fugitive call s:fugitive_init()
  autocmd FileType git call s:git_init()
augroup END

if exists('*setbufline') && !exists('$SSH_CLIENT')
  let s:git_cmd = ':Git!'
else
  let s:git_cmd = ':Git'
end

function! s:fugitive_init() abort
  let b:start    = s:git_cmd . ' push'
  execute "nnoremap <buffer> '<space> " . s:git_cmd . ' push<space>'
  " branch track
  nnoremap <buffer><silent> cbt :execute ':Git branch --set-upstream-to=origin/' . FugitiveHead()<cr>
  " merge force
  nnoremap <buffer> cmf :Git merge -X theirs<space>

  nnoremap <buffer> cp  :Git cherry-pick<space>
  nnoremap <buffer> cob :Git checkout -b<space>
  nnoremap <buffer> cbd :Git branch -d<space>
  nnoremap <buffer> cbD :Git branch -D<space>
endfunction

function! s:git_init() abort
  nnoremap <buffer> gd :DiffHistory<cr>
endfunction

"https://github.com/tpope/vim-fugitive/issues/132#issuecomment-649516204
command! DiffHistory call s:view_git_history()

function! s:view_git_history() abort
  Git difftool --name-only ! !^@
  call s:diff_current_quickfix_entry()
  " Bind <CR> for current quickfix window to properly set up diff split layout after selecting an item
  " There's probably a better way to map this without changing the window
  copen
  nnoremap <buffer> <CR> <CR><BAR>:call <sid>diff_current_quickfix_entry()<CR>
  wincmd p
endfunction

function s:diff_current_quickfix_entry() abort
  " Cleanup windows
  for window in getwininfo()
    if window.winnr !=? winnr() && bufname(window.bufnr) =~? '^fugitive:'
      " noautocmd that avoid exit vim on only one quickfix window
      noautocmd exe 'bdelete' window.bufnr
    endif
  endfor
  cc
  call s:add_mappings()
  let qf = getqflist({'context': 0, 'idx': 0})
  if get(qf, 'idx') && type(get(qf, 'context')) == type({}) && type(get(qf.context, 'items')) == type([])
    let diff = get(qf.context.items[qf.idx - 1], 'diff', [])
    for i in reverse(range(len(diff)))
      exe 'leftabove vert diffsplit' fnameescape(diff[i].filename)
      call s:add_mappings()
    endfor
  endif
endfunction

command! -nargs=1 -complete=customlist,fugitive#ReadComplete DiffBranch call s:diff_git_branch(<q-args>)

function! s:diff_git_branch(branch) abort
  execute 'Git difftool --name-status @ ' . a:branch 
  call s:diff_current_quickfix_entry()
  " Bind <CR> for current quickfix window to properly set up diff split layout after selecting an item
  " There's probably a better way to map this without changing the window
  copen
  nnoremap <buffer> <CR> <CR><BAR>:call <sid>diff_current_quickfix_entry()<CR>
  wincmd p
endfunction

function! s:add_mappings() abort
  nnoremap <buffer>]q :Cnext <BAR> :call <SID>diff_current_quickfix_entry()<CR>
  nnoremap <buffer>[q :Cprev <BAR> :call <SID>diff_current_quickfix_entry()<CR>
  " Reset quickfix height. Sometimes it messes up after selecting another item
  11copen
  wincmd p
endfunction
