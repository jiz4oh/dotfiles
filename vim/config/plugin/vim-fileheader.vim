let g:fileheader_delimiter_map = {
  \ 'markdown': { 'begin': '---', 'char': '', 'end': '---' }
  \ }

let g:fileheader_templates_map = {
  \ 'markdown': [
    \ 'date: {{created_date}}',
    \ 'updated: {{modified_date}}',
    \ ]
  \ }
