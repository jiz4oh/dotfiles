function! config#nerdtree#init() abort
  " Navigation
  nmap <Plug><ExpoloreToggle> :NERDTreeToggle<CR>
  imap <Plug><ExpoloreToggle> <c-o>:<c-u>NERDTreeToggle<CR>
  nmap <Plug><ExpoloreRoot>   :NERDTree<CR>
  nmap <Plug><ExpoloreCfile>  :NERDTreeFind<CR>

  " Command to call the OpenFileOrExplorer function.
  command! -n=? -complete=file -bar -bang E    :call <SID>OpenFileOrExplorer('<args>', <bang>0)
  command! -n=? -complete=file -bar -bang Edit :call <SID>OpenFileOrExplorer('<args>', <bang>0)
  silent! autocmd! nerd_loader
  silent! autocmd! FileExplorer
endfunction


" Function to open the file or NERDTree or netrw.
"   Returns: 1 if either file explorer was opened; otherwise, 0.
function! s:OpenFileOrExplorer(...)
  let edit_cmd = a:2 ? 'edit!' : 'edit'
  
  if a:0 == 0 || a:1 == ''
    " open NERDTree if current buffer is not a persisted file
    if empty(expand('%'))
      execute ':NERDTree' . personal#project#find_home()
    else
      " :Edit  "behave like edit
      " :Edit! "behave like edit
      execute edit_cmd
    endif
  elseif filereadable(expand(a:1))
    " :Edit  {file}  "behave like edit
    " :Edit! {file}  "behave like edit
    execute edit_cmd . ' ' . expand(a:1)
    return 0
  elseif a:1 =~? '^\(scp\|ftp\)://' " Add other protocols as needed.
    execute 'Vexplore '. a:1
  elseif isdirectory(expand(a:1))
    " :Edit {dir} " open NERDTree
    execute 'NERDTree '. expand(a:1)
  else
    return 0
  endif
  return 1
endfunction
