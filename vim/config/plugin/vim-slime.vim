let g:slime_no_mappings = 1
xmap <silent> gz  <Plug>SlimeRegionSend
nmap <silent> gz  <Plug>SlimeMotionSend
nmap <silent> gzz <Plug>SlimeLineSend
nmap <silent> gZ  <Plug>SlimeMotionSend$

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
  elseif exists('##TerminalWinOpen')
    let g:slime_target = 'vimterminal'

    function! s:remove(bufnr) abort
      if exists('*getbufinfo')
        let related_bufs = filter(getbufinfo(), {_, val -> has_key(val['variables'], "slime_config") 
              \ && get(val['variables']['slime_config'], 'bufnr', -1) == str2nr(a:bufnr)})
        
        for buf in related_bufs
          call setbufvar(buf['bufnr'], 'slime_config', {})
        endfor
      endif
    endfunction

    autocmd BufUnload * call <SID>remove(expand('<abuf>'))
  endif
augroup END
