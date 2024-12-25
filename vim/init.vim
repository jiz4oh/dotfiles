if get(g:, 'vimrc_loaded', 0) != 0
	finish
endif
let g:vimrc_loaded = 1

if exists('$_DOTFILES_PATH')
  let g:config_home = $_DOTFILES_PATH . '/vim'
else
  let g:config_home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
end

let g:plug_home = g:config_home . '/bundle'

exec 'source ' . g:config_home . '/config.vim'

function SourceConfig(configName) abort
    let l:vim_path = g:config_home . '/config/' . a:configName . '.vim'
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
execute 'source ' . g:config_home . '/autoload/plug.vim'
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

if g:as_ide && !get(g:, 'apple_terminal', 0)
  silent! colorscheme gruvbox-material
endif

let &packpath = &runtimepath

if filereadable($HOME . '/.vimrc.local')
  exec 'source' $HOME . '/.vimrc.local'
endif
