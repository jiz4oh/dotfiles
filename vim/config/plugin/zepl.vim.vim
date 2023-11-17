let g:repl_config = {
            \   'javascript': { 'cmd': 'node' },
            \   'ruby': { 'cmd': 'irb'},
            \   'vim': { 'cmd': 'vim -E'},
            \ }

function! s:cmd() abort
  let cmd = ''
  if !empty(get(b:, 'start', ''))
    let [cmd, opts] = personal#functions#parse_start(b:start)
  end
  return cmd
endfunction

nnoremap <silent> <leader>rr :execute 'botright 16 Repl ' . <SID>cmd()<cr>
nnoremap <silent> <leader>rk :execute 'botright keep 16 Repl ' . <SID>cmd()<cr>

if has('nvim')
  runtime zepl/contrib/nvim_autoscroll_hack.vim
endif

xnoremap '<CR> :<C-u>execute 'botright keep 16 Repl ' . <SID>cmd()<cr>gv:ReplSend<cr>
