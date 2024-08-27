nmap <leader>y  <Plug>OSCYankOperator
nmap <leader>yy <Plug>OSCYankOperator_
nmap <leader>Y  <Plug>OSCYankOperator$
vmap <leader>y  <Plug>OSCYankVisual

"https://github.com/neovim/neovim/pull/25872
"https://github.com/neovim/neovim/pull/26064
":h clipboard-osc52
if (!has('nvim') && !has('clipboard_working'))
  " In the event that the clipboard isn't working, it's quite likely that
  " the + and * registers will not be distinct from the unnamed register. In
  " this case, a:event.regname will always be '' (empty string). However, it
  " can be the case that `has('clipboard_working')` is false, yet `+` is
  " still distinct, so we want to check them all.
  let s:VimOSCYankPostRegisters = ['', '+', '*']
  function! s:VimOSCYankPostCallback(event)
    if a:event.operator == 'y' && index(s:VimOSCYankPostRegisters, a:event.regname) != -1
      call OSCYankRegister(a:event.regname)
    endif
  endfunction

  augroup VimOSCYankPost
    autocmd!
    autocmd TextYankPost * call s:VimOSCYankPostCallback(v:event)
  augroup END
endif
