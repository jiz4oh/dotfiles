if exists('g:project_markers')
  let g:floaterm_rootmarkers = g:project_markers
end

if executable('ranger')
  command! Ranger FloatermNew ranger
endif

if executable('yazi')
  command! Yazi FloatermNew yazi
endif

let g:floaterm_position = 'bottom'
let g:floaterm_autohide = '2'
let g:floaterm_keymap_toggle = '<m-=>'
let g:floaterm_width = 0.999999
let g:floaterm_height = 0.3

nnoremap <silent> <m--> :FloatermNew<cr>
function! s:init_floaterm() abort
  call Tnoremap('<m-->', ':FloatermNew<cr>', '<silent><buffer>')
  call Tnoremap('<m-[>', ':FloatermPrev<cr>', '<silent><buffer>')
  call Tnoremap('<m-]>', ':FloatermNext<cr>', '<silent><buffer>')
  nnoremap <silent><buffer> <m-[> :FloatermPrev<cr>
  nnoremap <silent><buffer> <m-]> :FloatermNext<cr>
endfunction

augroup vim-floaterm-augroup
  autocmd!
  autocmd FileType floaterm call <SID>init_floaterm()
augroup END
