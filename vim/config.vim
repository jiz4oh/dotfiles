let g:is_darwin         = has('mac')
let g:is_mac_gui        = has('mac') && (has('gui_running') || exists('g:neovide'))
let g:is_win            = has('win32') || has('win64')
" https://unix.stackexchange.com/a/78220
let g:has_linux_desktop = !empty($XDG_CURRENT_DESKTOP)

let g:notes_root              = $HOME . '/Notes'

" needs to be defined before vim-polyglot is loaded
let g:polyglot_disabled = ['sensible', 'autoindent', 'mermaid']

if has('nvim')
  let session_dir = has('nvim-0.3.1')
        \ ? stdpath('data').'/session'
        \ : has('win32')
        \   ? '~/AppData/Local/nvim-data/session'
        \   : '~/.local/share/nvim/session'
else " Vim
  let session_dir = has('win32')
        \ ? '~/vimfiles/session'
        \ : '~/.vim/session'
endif

let g:session_dir          = session_dir

let g:project_markers = [
      \'.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_',
      \'.fslckout', 'package.json', 'Gemfile', '.projections.json'
      \]

let g:is_iterm2 = 'iTerm.app' == $TERM_PROGRAM

let g:enable_nerd_font        = g:is_mac_gui || 
      \g:is_iterm2 ||
      \exists('$KITTY_WINDOW_ID') ||
      \exists('$WEZTERM_UNIX_SOCKET')
let g:as_ide                  = g:is_win || g:is_darwin || g:has_linux_desktop

" https://github.com/kovidgoyal/kitty/issues/957
let g:alt_compatible = exists('$KITTY_WINDOW_ID')
