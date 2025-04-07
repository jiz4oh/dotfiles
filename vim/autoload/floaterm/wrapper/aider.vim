function! floaterm#wrapper#aider#(cmd, jobopts, config) abort
  let original_dir = getcwd()
  " Change directory only if the current buffer has a valid, readable file
  let current_buf_name = bufname('%')
  if !empty(current_buf_name) && filereadable(current_buf_name)
    try
      lcd %:p:h
    catch
      echom 'Error changing directory: ' . v:exception
      " Decide if you want to proceed or return early
    endtry
  endif

  let cmdlist = split(a:cmd)
  if len(cmdlist) > 1
    let l:cmd = 'aider ' . join(cmdlist[1:], ' ')
  else
    let l:cmd = 'aider'
  endif

  " Get all visible buffers from windows
  let l:windows = getwininfo()
  let l:visible_bufnrs = {} " Use a dictionary to store unique buffer numbers
  for l:wininfo in l:windows
    " Ensure the buffer number is valid (greater than 0)
    if l:wininfo.bufnr > 0
      let l:visible_bufnrs[l:wininfo.bufnr] = 1 " Store bufnr as key for uniqueness
    endif
  endfor

  let l:files_to_add = []
  " Iterate through the unique buffer numbers (keys of the dictionary)
  for l:bufnr_str in keys(l:visible_bufnrs)
    let l:filename = fnamemodify(bufname(l:bufnr_str + 0), ':p')
    " Add buffer only if it's a real, readable file
    if !empty(l:filename) && filereadable(l:filename)
      call add(l:files_to_add, fnameescape(l:filename))
    endif
  endfor

  if !empty(l:files_to_add)
    let l:cmd .= ' ' . join(l:files_to_add, ' ')
  endif

  " Restore original directory if it was changed
  if getcwd() !=# original_dir
    try
      exe 'lcd ' . fnameescape(original_dir)
    catch
      echom 'Error restoring original directory: ' . v:exception
    endtry
  endif

  " Prepare command for execution as a list
  let l:cmd_list = [&shell, &shellcmdflag, l:cmd]
  return [v:false, l:cmd_list]
endfunction
