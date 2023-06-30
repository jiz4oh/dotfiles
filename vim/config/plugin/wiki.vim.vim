let g:wiki_filetypes          = ['md', 'wiki']
let g:wiki_link_extension     = '.md'
let g:wiki_link_target_type   = 'md'
let g:wiki_global_load        = 0

let g:wiki_journal = {
      \ 'name': 'journal',
      \ 'frequency': 'daily',
      \ 'date_format': {
      \   'daily' : '%Y/%m/%d',
      \   'weekly' : '%Y/week_%V',
      \   'monthly' : '%Y/%m/summary',
      \ },
      \ 'index_use_journal_scheme': v:true,
      \}

let g:wiki_mappings_local_journal = {
      \ '<plug>(wiki-journal-prev)' : '[w',
      \ '<plug>(wiki-journal-next)' : ']w',
      \}

let g:wiki_map_text_to_link = 'MyTextToLink'
function MyTextToLink(text) abort
  return [substitute(tolower(a:text), '\s\+', '-', 'g'), a:text]
endfunction

augroup wiki-vim-augroup
  autocmd!

if exists('g:notes_root')
  let g:wiki_root = g:notes_root
  let s:root = resolve(expand(g:notes_root))

  function! s:init_for_obsidian() abort
    " https://forum.obsidian.md/t/open-note-in-obsidian-from-within-vim-and-vice-versa/6837
    " Open file in Obsidian vault
    let vault = UrlEncode(fnamemodify(s:root, ':t'))
    let relative_path = substitute(resolve(expand('%:p')), s:root, '', '')
    let file = escape(UrlEncode(relative_path), '%')
    let url = 'obsidian://open?vault=' . vault  . '&file=' . file
    " let url = 'obsidian://open?path=' . expand('%:p')
    let b:dispatch = 'open "'.url.'"'
  endfunction

  execute 'autocmd BufEnter ' . join([s:root, '*.md'], '/') . ' call s:init_for_obsidian()'
endif

augroup END
