let g:fzf_mru_no_sort = 1

command! -nargs=? FZFMru call fzf_mru#actions#mru(<q-args>, fzf#vim#with_preview({'options': '--no-sort --prompt "MRU>"'}))
command! -nargs=? FZFFreshMru call fzf_mru#mrufiles#refresh() <bar> call fzf_mru#actions#mru(<q-args>, fzf#vim#with_preview({'options': '--no-sort --prompt "MRU>"'}))

nnoremap <leader>sf :FZFMru<cr>

if g:is_win
  let g:fzf_mru_exclude = '^D:\\temp\\.*'           " For MS-Windows
else
  let g:fzf_mru_exclude = '^/tmp/.*\|^/var/tmp/.*'
  " ignore session
  let g:fzf_mru_exclude .= '\|Session.vim\|^'. resolve(expand(g:session_dir)) . '/.*'
  let g:fzf_mru_exclude .= '\|.git/.*MSG'
  let g:fzf_mru_exclude .= '\|/private/var/*'
  let g:fzf_mru_exclude .= '\|/var/*'
endif

function! MRUCwd(...) abort
  let files = fzf_mru#mrufiles#source()[0: a:1 - 1]
  return map(files, { _, val -> {
        \ 'line': val,
        \ 'path': val
        \}})
endfunction
