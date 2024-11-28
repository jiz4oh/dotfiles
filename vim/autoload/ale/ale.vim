call ale#fix#registry#Add('zeroapifmt',
      \'ale#fixers#zeroapifmt#Fix', 
      \[
      \'zeroapi',
      \], 
      \'Correct spaces, words, and punctuations between CJK (Chinese, Japanese, Korean). '
      \)

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

