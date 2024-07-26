if get(g:, 'vimrc_loaded', 0) != 0
	finish
endif
let g:vimrc_loaded = 1

let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')

exec 'source ' . s:home . '/config.vim'

function SourceConfig(configName) abort
    let l:vim_path = s:home . '/config/' . a:configName . '.vim'
    if filereadable(l:vim_path)
      exec 'source ' . l:vim_path
    endif
endfunction

function! HasInstall(plugName) abort
    let spec = get(get(g:, 'plugs', {}), a:plugName, {})
    if empty(spec)
      return 0
    endif
    " 判断插件是否已经安装在本地
    return isdirectory(g:plugs[a:plugName].dir)
endfunction

call SourceConfig('base')
execute 'source ' . s:home . '/autoload/plug.vim'
call SourceConfig('plugin')

" https://github.com/neovide/neovide/discussions/1220
if exists('g:neovide')
  let g:neovide_input_use_logo=v:true
  " copy
  xnoremap <D-c> "+y

  " paste
  nnoremap <D-v> "+p
  inoremap <D-v> <Esc>"+pa
  cnoremap <D-v> <c-r>+
  tnoremap <D-v> <C-\><C-n>"+pi<right>

  " undo
  nnoremap <D-z> u
  inoremap <D-z> <Esc>ua

  " others
  if has('mac')
    nmap <silent> <D-C-f> :let g:neovide_fullscreen = get(g:, "neovide_fullscreen", 0) == 0 ? 1 : 0<cr>
  endif
endif

augroup PlugLazyLoad
  autocmd!

  if exists('g:plugs_order')
    for plugName in g:plugs_order
      if HasInstall(plugName)
        let spec = g:plugs[plugName]
        "TODO plug.vim 内部判断某个插件是否 lazy，不只是判断是否有 on 或者 for
        " if has_key(spec, 'on') || has_key(spec, 'for')
        "   execute 'autocmd User ' . plugName . ' call SourceConfig("plugin/' . plugName . '")'
        " else
          call SourceConfig('plugin/' . plugName)
        " endif
      endif
    endfor
  endif
augroup END

let &packpath = &runtimepath

if filereadable($HOME . '/.vimrc.local')
  exec 'source' $HOME . '/.vimrc.local'
endif
