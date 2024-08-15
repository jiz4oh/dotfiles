if exists('g:project_markers')
  let g:asyncrun_rootmarks = g:project_markers
end

let g:asynctasks_term_pos = 'floaterm'

if get(g:, 'is_darwin')
  let g:asynctasks_system = 'macos'
endif

function! s:fzf_sink(what)
	let p1 = stridx(a:what, '<')
	if p1 >= 0
		let name = strpart(a:what, 0, p1)
		let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
		if name !=# ''
			call feedkeys(':AsyncTask '. fnameescape(name))
      call feedkeys("\<CR>")
		endif
	endif
endfunction

function! s:fzf_task()
	let rows = asynctasks#source(&columns * 48 / 100)
	let source = []
	for row in rows
		let name = row[0]
		let source += [name . '  ' . row[1] . '  : ' . row[2]]
	endfor
	let opts = { 'source': source, 'sink': function('s:fzf_sink'),
				\ 'options': '+m --nth 1 --inline-info --tac' }
	if exists('g:fzf_layout')
		for key in keys(g:fzf_layout)
			let opts[key] = deepcopy(g:fzf_layout[key])
		endfor
	endif
	call fzf#run(opts)
endfunction

command! -nargs=0 AsyncTaskFzf call s:fzf_task()

nnoremap <leader>sT     :AsyncTaskFzf<cr>

nnoremap <leader>m<space> :AsyncTask<space>
nnoremap <leader>mf       :AsyncTask file-build<cr>
nnoremap <leader>mp       :AsyncTask project-build -make=
nnoremap <leader>mr       :AsyncTask project-run<cr>
