let $FZF_DEFAULT_OPTS="--reverse --bind 'change:first,alt-n:page-down,alt-p:page-up,alt-j:preview-down,alt-k:preview-up'"
let g:fzf_preview_window = ['down:60%', 'ctrl-/']

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'
  \}

" jump to existed window if possible
let g:fzf_buffers_jump = 1
let g:fzf_history_dir = '~/.local/share/fzf-history'
if exists('$TMUX')
  let g:fzf_layout = { 'tmux': '-p90%,60%' }
elseif has('nvim') || has('patch-8.2.191')
  let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }
else
  " disable popup in favor of location window
  let g:fzf_layout = { 'down': '60%' }
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
