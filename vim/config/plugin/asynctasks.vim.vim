if exists('g:project_markers')
  let g:asyncrun_rootmarks = g:project_markers
end

let g:asynctasks_term_pos = 'floaterm'

if get(g:, 'is_darwin')
  let g:asynctasks_system = 'macos'
endif

nnoremap <leader>m<space> :AsyncTask<space>
nnoremap <leader>mf       :AsyncTask file-build<cr>
nnoremap <leader>mp       :AsyncTask project-build -make=
nnoremap <leader>mr       :AsyncTask project-run<cr>
nnoremap '<CR>            :AsyncTask .file-repl<CR>
xnoremap `<CR>            :AsyncTask file-run<cr>
nnoremap `<CR>            :AsyncTask file-run<cr>
