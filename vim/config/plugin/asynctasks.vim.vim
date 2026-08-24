if exists('g:project_markers')
  let g:asyncrun_rootmarks = g:project_markers
end

let g:asynctasks_term_pos = 'floaterm'

if get(g:, 'is_darwin')
  let g:asynctasks_system = 'macos'
endif

command! -nargs=0 AsyncTaskFzf call v:lua.require('config.picker').async_tasks(asynctasks#source(&columns * 48 / 100))
command! -nargs=0 AsyncTaskSelect AsyncTaskFzf

nnoremap <leader>sT     :AsyncTaskFzf<cr>

nnoremap <leader>m<space> :AsyncTask<space>
nnoremap <leader>mf       :AsyncTask file-build<cr>
nnoremap <leader>mp       :AsyncTask project-build -make=
nnoremap <leader>mr       :AsyncTask project-run<cr>
