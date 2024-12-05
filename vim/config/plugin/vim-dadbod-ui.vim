let g:dbs = {
\ 'mysql': 'mysql://root@localhost/mysql',
\ 'mysql_sys': 'mysql://root@localhost/sys',
\ 'mysql_information_schema': 'mysql://root@localhost/information_schema',
\ 'reids_development': 'redis:0',
\ }

" ~/.local/share/db_ui/connections.json
let g:db_ui_save_location = '~/.local/share/db_ui'

let g:db_ui_use_nerd_fonts = get(g:, 'enable_nerd_font', 0)
let g:db_ui_auto_execute_table_helpers = 1

nmap  <silent> <leader>ed :tabnew<CR>:DBUIToggle<CR>

augroup dbui_zvim
  autocmd!
  autocmd FileType dbui call s:dbui_init()
  autocmd User ProjectionistActivate call s:activate_projectionist()
augroup END

function! s:dbui_init() abort
  nnoremap <silent><buffer> <leader>, :execute 'tabedit'. g:db_ui_save_location . '/connections.json'<CR>
  nnoremap <silent><buffer> h <Plug>(DBUI_GotoParentNode)<Plug>(DBUI_SelectLine)
  nnoremap <silent><buffer> l <Plug>(DBUI_GotoChildNode)
endfunction

function! s:activate_projectionist() abort
  if get(b:, 'db', 0)
    return
  end

  let url = ''
  for [_root, value] in projectionist#query('db')
      try
        lua require("lazy").load({ plugins = { "vim-dadbod-ui" } })
      catch
      endtry
    for v in db_ui#connections_list()
      if v['name'] ==# value
        let url = v['url']
        break
      end
    endfor
    if url != ''
      break
    end
  endfor

  if url != ''
    call setbufvar(bufnr(), 'db', url)
  endif
endfunction
