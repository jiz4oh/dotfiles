let g:is_darwin         = has('mac')
let g:is_mac_gui        = has('mac') && (has('gui_running') || exists('g:neovide'))
let g:is_win            = has('win32') || has('win64')
" https://unix.stackexchange.com/a/78220
let g:has_linux_desktop = !empty($XDG_CURRENT_DESKTOP)

let g:notes_root              = $HOME . '/Notes'

" needs to be defined before vim-polyglot is loaded
let g:polyglot_disabled = ['sensible', 'autoindent', 'mermaid']

let ruby_operators        = 1
let ruby_pseudo_operators = 1
let ruby_no_expensive     = 1

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
      \'.fslckout', 'package.json', 'Gemfile', '.projections.json',
      \'go.mod', 'requirements.txt'
      \]

let g:is_iterm2 = 'iTerm.app' == $TERM_PROGRAM

let g:enable_nerd_font        = g:is_mac_gui || 
      \g:is_iterm2 ||
      \'xterm-kitty' == $TERM ||
      \exists('$KITTY_WINDOW_ID') ||
      \exists('$WEZTERM_UNIX_SOCKET')
let g:as_ide                  = g:is_win || g:is_darwin || g:has_linux_desktop

" https://github.com/kovidgoyal/kitty/issues/957
let g:alt_compatible = 'xterm-kitty' == $TERM || exists('$KITTY_WINDOW_ID')

let g:which_key_map = {}

let g:which_key_map['/'] = 'clear highlight'
let g:which_key_map['1'] = 'tab-1'
let g:which_key_map['2'] = 'tab-2'
let g:which_key_map['3'] = 'tab-3'
let g:which_key_map['4'] = 'tab-4'
let g:which_key_map['5'] = 'tab-5'
let g:which_key_map['6'] = 'tab-6'
let g:which_key_map['7'] = 'tab-7'
let g:which_key_map['8'] = 'tab-8'
let g:which_key_map['9'] = 'tab-9'
let g:which_key_map['y']  = 'Yank {motion} to clipboard'
let g:which_key_map['yy'] = 'Yank current line to clipboard'
let g:which_key_map['Y']  = 'Yank from the cursor to the end of line to clipboard'
let g:which_key_map['-']  = 'decrease window height, and can be repeat by dot'
let g:which_key_map['+']  = 'increase window height, and can be repeat by dot'
let g:which_key_map['<']  = 'decrease window width, and can be repeat by dot'
let g:which_key_map['>']  = 'increase window width, and can be repeat by dot'

let g:which_key_map[' '] = {
      \ 'name' : '+easymotion' ,
      \ 'f' : ['<plug>(easymotion-prefix)f' , 'find {char} to the right'],
      \ 'F' : ['<plug>(easymotion-prefix)F' , 'find {char} to the left'],
      \ 't' : ['<plug>(easymotion-prefix)t' , 'till before the {char} to the right'],
      \ 'T' : ['<plug>(easymotion-prefix)T' , 'till after the {char} to the left'],
      \ 'w' : ['<plug>(easymotion-prefix)w' , 'beginning of word forward'],
      \ 'W' : ['<plug>(easymotion-prefix)W' , 'beginning of WORD forward'],
      \ 'b' : ['<plug>(easymotion-prefix)b' , 'beginning of word backward'],
      \ 'B' : ['<plug>(easymotion-prefix)B' , 'beginning of WORD backward'],
      \ 'e' : ['<plug>(easymotion-prefix)e' , 'end of word forward'],
      \ 'E' : ['<plug>(easymotion-prefix)E' , 'end of WORD forward'],
      \ 'g' : {
        \ 'name' : '+Backwards ' ,
        \ 'e' : ['<plug>(easymotion-prefix)ge' , 'end of word backward'],
        \ 'E' : ['<plug>(easymotion-prefix)gE' , 'end of WORD backward'],
        \ },
      \ 'j' : ['<plug>(easymotion-prefix)j' , 'line downward'],
      \ 'k' : ['<plug>(easymotion-prefix)k' , 'line upward'],
      \ 'n' : ['<plug>(easymotion-prefix)n' , 'jump to latest "/" or "?" forward'],
      \ 'N' : ['<plug>(easymotion-prefix)N' , 'jump to latest "/" or "?" backward.'],
      \ 's' : ['<plug>(easymotion-prefix)s' , 'find(search) {char} forward and backward.'],
      \ }

let g:which_key_map['c'] = {
      \ 'name' : '+Close/Change',
      \ 'd' : {
        \ 'name': 'Directory',
        \ '.'   : 'Change work Directory to the directory containing the buffer',
        \ 'p'   : 'Change work Directory to the Project root'
        \}
      \}

let g:which_key_map['d'] = {
      \ 'name' : '+Database',
      \ 'b' : 'run the {motion} as sql',
      \ 'bb' : 'run the current line as sql',
      \}

let g:which_key_map['e'] = {
      \ 'name' : '+Explorer',
      \ 'e': 'open file Explorer',
      \ 'p': 'open file explorer of Project root',
      \ 'f': 'open file explorer and locate current buffer',
      \ 'd': 'open Db connector',
      \ 'q': 'open Quickfix list',
      \ 't': 'open Tagbar',
      \ 'g': 'open fugitive',
      \ 's': 'open Startify',
      \ }

let g:which_key_map['f'] = {
      \ 'name' : '+Format/Fix/File',
      \ 'f': 'Fix by ale',
      \ 't': 'show one or all warnings',
      \ 'r': 'Rename current file',
      \ }


let g:which_key_map['g'] = {
      \ 'name' : '+Git/version-control',
      \ 'g': 'open fugitive',
      \ 'd': 'perform a vimDiff against the current buffer',
      \ 'b': 'run git-Blame on the current file',
      \ 'l': 'open git Log of current buffer',
      \ 'L': 'open git Log',
      \ 'x': 'open the current file, blob, tree, commit, or tag in your browser',
      \ }

let g:which_key_map['h'] = {
      \ 'name' : '+Hunk',
      \ 'p' : 'Preview Hunk',
      \ 's' : 'Stage Hunk',
      \ 'u' : 'Undo Hunk',
      \ 'f' : 'Fold all unchange lines',
      \ }

let g:which_key_map['l'] = {
      \ 'name' : '+Lsp',
      \ 'd' : 'find Definitions',
      \ 'D' : 'find Declarations',
      \ 't' : 'find Type definitions',
      \ 'i' : 'find Implementations',
      \ 'r' : 'find References',
      \ 'R' : 'Rename',
      \ 's' : 'find Symbols on current buffer',
      \ 'S' : 'find Symbols on workspace',
      \ 'f' : 'Format a {motion}',
      \ 'F' : 'recalculate Folds for the current buffer',
      \ 'K' : 'show documentation of current symbol',
      \ }

let g:which_key_map['s'] = {
      \ 'name' : '+Search',
      \ ' ': 'Search with ripgrep',
      \ '/': 'Search search history',
      \ ':': 'Search command history',
      \ 'i': 'Search Include files',
      \ 'g': 'Search in Gems',
      \ 'p': 'Search in Project',
      \ 't': 'Search <cword> in Tags',
      \ 'b': 'Search lines in the current Buffer',
      \ 'm': 'Search Marks',
      \ 's': 'Search available Sessions',
      \ }

let g:which_key_map['w'] = {
      \ 'name' : '+Wiki/Window',
      \ '1' : 'window-1'  ,
      \ '2' : 'window-2'  ,
      \ '3' : 'window-3'  ,
      \ '4' : 'window-4'  ,
      \ '5' : 'window-5'  ,
      \ '6' : 'window-6'  ,
      \ '7' : 'window-7'  ,
      \ '8' : 'window-8'  ,
      \ '9' : 'window-9'  ,
      \ 'l' : {
        \   'name' : '+wiki-link',
        \ }
      \ }

let g:which_key_map['t'] = {
      \ 'name' : '+Tab/Test',
      \ 'n' : 'New Tab',
      \ 'r' : 'Test nearest to the cursor',
      \ 'f' : 'Test current File or last File',
      \ 'a' : 'run whole Test suite of current file or last file',
      \ 'l' : 'run the Last Test',
      \ '''' : {
      \   'name' : '+Start',
      \   }
      \ }

let g:which_key_map_visual = {}

let g:which_key_map_visual['d'] = {
      \ 'name' : '+Database',
      \ 'b' : 'run the selected content as sql',
      \}

let g:which_key_map_visual['y'] = 'Yank to clipboard'

let g:which_key_map_visual['h'] = {
      \ 'name' : '+Hunk',
      \ 's' : 'Stage Hunk',
      \ }

let g:which_key_map_visual['l'] = {
      \ 'name' : '+Lsp',
      \ 'f   ' : 'Format Selected',
      \ }


let g:which_key_map_visual['g'] = {
      \ 'name' : '+Git/version-control',
      \ 'b': 'run git-Blame on the current file',
      \ 'l': 'open git Log of selected lines',
      \ 'x': 'open the selected lines in your browser',
      \ }

let g:which_key_map_visual['s'] = {
      \ 'name' : '+Search',
      \ ' ': 'Search selected with ripgrep',
      \ 'g': 'Search selected in Gems',
      \ 'p': 'Search selected in Project',
      \ 'w': 'Search selected in cWd',
      \ }
