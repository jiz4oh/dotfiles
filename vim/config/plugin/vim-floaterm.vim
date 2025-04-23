if exists('g:project_markers')
  let g:floaterm_rootmarkers = g:project_markers
end

if executable('ranger')
  command! Ranger FloatermNew --position=center --height=0.7 ranger
endif

if executable('yazi')
  command! Yazi FloatermNew --position=center --height=0.7 yazi
endif

command! -nargs=* Aider FloatermNew --name=Aider --position=topright --width=0.4 --height=0.99999999999 aider --no-pretty --no-auto-commits <args>

let g:floaterm_position = 'bottom'
let g:floaterm_autohide = '2'
let g:floaterm_keymap_toggle = '<m-=>'
let g:floaterm_width = 0.999999
let g:floaterm_height = 0.3

nnoremap <silent> <m--> :FloatermNew<cr>
function! s:init_floaterm() abort
  call Tnoremap('<m-->', '<cmd>FloatermNew<cr>', '<silent><buffer>')
  call Tnoremap('<m-[>', '<cmd>FloatermPrev<cr>', '<silent><buffer>')
  call Tnoremap('<m-]>', '<cmd>FloatermNext<cr>', '<silent><buffer>')
  nnoremap <silent><buffer> <m-[> :FloatermPrev<cr>
  nnoremap <silent><buffer> <m-]> :FloatermNext<cr>
endfunction

function! FloatermHide(...) abort
  if a:0 > 0
    let bufnr = a:1
  else
    let bufnr = bufnr()
  endif
  let ft = getbufvar(bufnr, '&filetype')
  noautocmd call setbufvar(bufnr, '&filetype', 'floaterm')
  call floaterm#window#hide(bufnr)
  noautocmd call setbufvar(bufnr, '&filetype', ft)
endfunction

augroup vim-floaterm-augroup
  autocmd!
  autocmd FileType floaterm,REPL call <SID>init_floaterm()
augroup END
