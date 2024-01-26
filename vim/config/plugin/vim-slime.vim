function! s:reset(map) abort
  if exists('*s:check') 
    call s:check()
  endif

  if exists('b:slime_config') && empty(get(b:, 'slime_config')) 
    unlet b:slime_config 
  endif
  return a:map
endfunction

let g:slime_no_mappings = 1
xmap <silent><expr> gz <SID>reset('<Plug>SlimeRegionSend')
nmap <silent><expr> gz <SID>reset('<Plug>SlimeMotionSend')
nmap <silent><expr> gzz <SID>reset('<Plug>SlimeLineSend')
nmap <silent><expr> gZ <SID>reset('<Plug>SlimeMotionSend$')

" https://github.com/pry/pry/issues/1524#issuecomment-237309299
" https://github.com/pry/pry/issues/1524#issuecomment-276117072
" so that I can paste multiple lines in pry/ruby like
" foo
"  .bar
"  .baz
function! g:_EscapeText_ruby(text)
  return ["(\n", a:text, ")\n"]
endfunction

augroup vim-slime-augroup
  autocmd!

  if has('nvim')
    let g:slime_target = 'neovim'

    function! s:remove() abort
      let current_buffer_jobid = get(b:,"terminal_job_id",-1)

      let related_bufs = filter(getbufinfo(), {_, val -> has_key(val['variables'], "slime_config")
          \ && get(val['variables']['slime_config'], 'jobid', -2) == current_buffer_jobid})

      for buf in related_bufs
        call setbufvar(buf['bufnr'], 'slime_config', {})
      endfor
    endfunction

    "TODO removed after https://github.com/jpalardy/vim-slime/pull/416 merged
    autocmd TermClose * call <SID>remove()
  elseif exists('##TerminalWinOpen')
    let g:slime_target = 'vimterminal'

    function! s:check()
      let bufnr = get(get(b:, 'slime_config', {}), 'bufnr')
      
      if !bufexists(bufnr)
        call setbufvar(bufnr(), 'slime_config', {})
      endif
    endfunction
  endif
augroup END
