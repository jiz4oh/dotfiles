if !exists('*MRUCwd')
  function! MRUCwd() abort
    return []
  endfunction
endif

if exists('g:session_dir')
  let g:startify_session_dir          = g:session_dir
endif

let g:startify_skiplist               = ['^/mnt/nfs']
let g:startify_change_to_dir          = 1
let g:startify_relative_path          = 1
let g:startify_files_number           = 10
let g:startify_session_delete_buffers = 1
let g:startify_session_persistence    = 1
let g:startify_session_before_save    = [
    \ 'echo "Cleaning up before saving.."',
    \ 'silent! NERDTreeTabsClose'
    \ ]
let g:startify_session_remove_lines   = ['_loaded']            " let plugin load agian

let g:startify_session_savevars = [
    \ 'g:startify_session_savevars',
    \ 'g:startify_session_savecmds',
    \ 'g:startify_session_remove_lines',
    \ 'MRU_Exclude_Files',
    \ ]

let g:_startify_bookmarks = [
            \ $MYVIMRC,
            \ ]
let g:startify_bookmarks = copy(g:_startify_bookmarks)

" returns all modified files of the current git repo
" `2>/dev/null` makes the command fail quietly, so that when we are not
" in a git repo, the list will be empty
let g:startify_lists = [
        \ { 'type': 'bookmarks',                                       'header': ['   Bookmarks']               },
        \ { 'type': function('MRUCwd', [g:startify_files_number]),     'header': ['   MRU']                     },
        \ { 'type': 'commands',                                        'header': ['   Commands']                },
        \ ]

if get(g:, 'lazy_did_setup', 0)
  let install = 'Lazy install'
  let update = 'Lazy update'
else
  let install = 'PlugInstall'
  let update = 'PlugUpdate'
end

let g:startify_commands = [
    \ {'d': ['Databases',       'tabnew | DBUI']      },
    \ {'u': ['Update Plugins',  update]  },
    \ {'i': ['Install Plugins', install] },
    \ {'b': ['Delete Bookmark', 'StartifyDeleteBookmark'] },
    \ ]

function! LoadSession(name) abort
  execute 'SLoad ' . a:name
endfunction

let s:ignore = ['__LAST__', 'tags']
function! GetSessions() abort
  if !isdirectory(g:session_dir)
    call mkdir(fnamemodify(g:session_dir, ':p'), 'p')
  endif

  return filter(systemlist('ls ' . g:session_dir), 'index(s:ignore, v:val) == -1')
endfunction

function! SaveSession() abort
  if empty(v:this_session) && index(['startify'], &filetype) < 0
    SSave! default
  end
  SClose
endfunction

let s:bookmarks = []
let s:bookmark_file = expand('~/.cache/startify_bookmarks')
if filereadable(s:bookmark_file)
  let s:bookmarks = readfile(s:bookmark_file)
  call extend(g:startify_bookmarks, s:bookmarks)
endif

function! s:save_bookmarks()
  call writefile(s:bookmarks, s:bookmark_file)
endfunction

function! s:add_bookmark(bookmark)
  if !exists('g:startify_bookmarks')
    let g:startify_bookmarks = []
  endif
  if a:bookmark ==# ""
    let bookmark = expand('%:p')
  else
    let bookmark = a:bookmark
  end
  let s:bookmarks += [ bookmark ]
  let g:startify_bookmarks += [ bookmark ]
endfunction

function! StarifyOnDeleteBookmark(item, idx) abort
  call remove(s:bookmarks, a:idx)
  let g:startify_bookmarks = extend(copy(g:_startify_bookmarks), s:bookmarks)
endfunction

function! s:delete_bookmark()
  call select#input('Delete bookmark> ', s:bookmarks, function('StarifyOnDeleteBookmark'))
endfunction

augroup vim-startify-augroup
  autocmd!

  autocmd VimLeave * call <sid>save_bookmarks()
  autocmd filetype startify setlocal foldlevel=99
augroup END

command! -nargs=? StartifyAddBookmark call <sid>add_bookmark(<q-args>)
command! -nargs=? StartifyDeleteBookmark call <sid>delete_bookmark()

nnoremap <silent> <leader><tab> :Startify<cr>
