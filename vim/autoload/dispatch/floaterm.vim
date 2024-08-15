" dispatch.vim floaterm strategy

if exists('g:autoloaded_dispatch_floaterm')
  finish
endif
let g:autoloaded_dispatch_floaterm = 1

let s:width = 0.5
let s:height = 0.3

" request = {
  " file: string,
  " action: string,
  " bufnr: int,
  " pid: int,
  " background: bool,
  " mods: string,
  " directory: string,
  " expanded: string,
" }
function! dispatch#floaterm#handle(request) abort
  if !(exists('g:loaded_floaterm')) || a:request.background
    return 0
  endif

  let s:action = a:request.action

  if s:action ==# 'start'
    let a:request.pid = dispatch#floaterm#start(a:request)
  else
    return 0
  endif

  return 1
endfunction

function! s:exit(request, job, status, ...) abort
endfunction

function! dispatch#floaterm#activate(pid) abort
  call floaterm#terminal#open_existing(str2nr(a:pid))
  return 1
endfunction

function! dispatch#floaterm#running(pid) abort
  return bufexists(str2nr(a:pid))
endfunction

function! dispatch#floaterm#start(request) abort
  let cmd = a:request.expanded
  let jobopts = {
        \ 'on_exit': function('s:exit', [a:request]),
        \ }
  let config = {
        \ 'cwd': a:request.directory,
        \ 'title': a:request.title . ' ($1/$2)',
        \ 'name': a:request.expanded,
        \}

  if !empty(a:request.mods)
    if g:floaterm_wintype !=# 'float'
      let config.position = a:request.mods
    elseif a:request.mods =~# 'leftabove' || a:request.mods =~# 'aboveleft' || a:request.mods =~# 'topleft'
      if a:request.mods =~# 'vertical'
        let config.position = 'left'
      elseif a:request.mods =~# 'horizontal'
        let config.position = 'top'
      elseif &splitright
        let config.position = 'top'
      else
        let config.position = 'left'
      end
    elseif a:request.mods =~# 'rightbelow' || a:request.mods =~# 'belowright' || a:request.mods =~# 'botright'
      if a:request.mods =~# 'vertical'
        let config.position = 'right'
      elseif a:request.mods =~# 'horizontal'
        let config.position = 'bottom'
      elseif &splitright
        let config.position = 'right'
      else
        let config.position = 'bottom'
      end
    end

    if get(config, 'position', '') ==# 'left' || get(config, 'position', '') ==# 'right'
      let config.width = s:width
      let config.height = 0.999999
    elseif get(config, 'position', '') ==# 'top' || get(config, 'position', '') ==# 'bottom'
      let config.width = 0.999999
      let config.height = s:height
    end
  end
  return floaterm#terminal#open(-1, cmd, jobopts, config)
endfunction
