function! s:extend_linters(map)
  for filetype in keys(a:map)
    call extend(a:map[filetype], get(g:ale_linters, '*', []), 'keep')
  endfor

  return a:map
endfunction

function! s:extend_fixers(map)
  for filetype in keys(a:map)
    call extend(a:map[filetype], get(g:ale_fixers, '*', []), 'keep')
  endfor

  return a:map
endfunction

augroup ale_augroup
  autocmd BufRead,BufNewFile */.github/*/*.y{,a}ml
      \ let b:ale_linters = {'yaml': ['actionlint']}

  autocmd BufRead,BufNewFile *.html.erb
      \ let b:ale_fixers = ['erblint', 'prettier-eslint']
augroup END

function! FixTypescript(buffer) abort
  try
    TSToolsOrganizeImports
    TSToolsAddMissingImports
    TSToolsFixAll
  catch
  endtry
endfunction

call ale#fix#registry#Add('typescript-tools',
      \'FixTypescript', 
      \[
      \'typescript',
      \'typescript.tsx',
      \], 
      \'add missing imports, sorts and removes unused imports, fixes all fixable errors'
      \)

call ale#fix#registry#Add('xml_tidy',
      \'ale#fixers#xml_tidy#Fix', 
      \[
      \'xml',
      \], 
      \'Fix XML files with tidy'
      \)
