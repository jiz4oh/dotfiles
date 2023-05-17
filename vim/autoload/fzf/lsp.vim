function! s:not_supported(what) abort
    return lsp#utils#error(printf("%s not supported for filetype '%s'", a:what, &filetype))
endfunction

function! s:fzf(type, list, fullscreen) abort
  let actions = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit'
    \}

  let l:dir = getcwd()
  let l:spec = {
                \'dir': l:dir,
                \'sink*': { lines -> fzf#helper#colon_sink(lines, 1, l:actions) },
                \'source': a:list,
                \'options': [
                  \'--expect', join(keys(l:actions), ','),
                  \'--ansi',
                  \'--prompt', a:type. '> ',
                  \'--multi', '--bind', 'alt-a:select-all,alt-d:deselect-all',
                  \'--delimiter', ':',
                  \'--nth', '3..',
                  \'--preview-window', '+{2}-/2'
                \]}

  call fzf#run(fzf#wrap(fzf#vim#with_preview(l:spec), a:fullscreen))
endfunction

function! fzf#lsp#workspace_symbol(query, fullscreen) abort
    let l:servers = filter(lsp#get_allowed_servers(), 'lsp#capabilities#has_workspace_symbol_provider(v:val)')
    let l:command_id = lsp#_new_command()

    if len(l:servers) == 0
        call s:not_supported('Retrieving workspace symbols')
        return
    endif

    if !empty(a:query)
        let l:query = a:query
    else
        let l:query = inputdialog('query>', '', "\<ESC>")
        if l:query ==# "\<ESC>"
            return
        endif
    endif

    for l:server in l:servers
        call lsp#send_request(l:server, {
            \ 'method': 'workspace/symbol',
            \ 'params': {
            \   'query': l:query,
            \ },
            \ 'on_notification': function('s:handle_symbol', [l:server, l:command_id, a:fullscreen, 'workspaceSymbol']),
            \ })
    endfor

    redraw | echo 'Retrieving workspace symbols ...'
endfunction

function! fzf#lsp#document_symbol(fullscreen) abort
    let l:servers = filter(lsp#get_allowed_servers(), 'lsp#capabilities#has_document_symbol_provider(v:val)')
    let l:command_id = lsp#_new_command()

    if len(l:servers) == 0
        call s:not_supported('Retrieving symbols')
        return
    endif

    for l:server in l:servers
        call lsp#send_request(l:server, {
            \ 'method': 'textDocument/documentSymbol',
            \ 'params': {
            \   'textDocument': lsp#get_text_document_identifier(),
            \ },
            \ 'on_notification': function('s:handle_symbol', [l:server, l:command_id, a:fullscreen, 'documentSymbol']),
            \ })
    endfor

    redraw | echo 'Retrieving document symbols ...'
endfunction

let s:ansi = {
  \'reset': nr2char(0x001b). '[0m',
  \'red': nr2char(0x001b). '[31m',
  \'green': nr2char(0x001b). '[32m',
  \'yellow': nr2char(0x001b). '[33m',
  \'blue': nr2char(0x001b). '[34m',
  \'purple': nr2char(0x001b). '[35m'
  \}

" val = {
"   'filename',
"   'lnum',
"   'col',
"   'text',
" }
function! s:format_symbol_entry(val) abort
  let l:filename = printf('%s%s%s', s:ansi.purple, fnamemodify(a:val.filename, ':~:.'), s:ansi.reset)
  let l:lnum = printf('%s%s%s', s:ansi.green, a:val.lnum, s:ansi.reset)
  let l:col = a:val.col
  let l:s = split(a:val.text, ' : ')
  let l:kind = l:s[0]
  let l:name = join(l:s[1:], ' : ')

  let l:text = '[' . printf('%s%s%s', s:ansi.red, l:kind, s:ansi.reset) . '] ' . l:name

  return printf('%s:%s:%s: %s', l:filename, l:lnum, l:col, l:text)
endfunction

function! s:handle_symbol(server, last_command_id, fullscreen, type, data) abort
    if a:last_command_id != lsp#_last_command()
        return
    endif

    if lsp#client#is_error(a:data['response'])
        call lsp#utils#error('Failed to retrieve '. a:type . ' for ' . a:server . ': ' . lsp#client#error_message(a:data['response']))
        return
    endif

    let l:list = lsp#ui#vim#utils#symbols_to_loc_list(a:server, a:data)

    if empty(l:list)
      call lsp#utils#error('No ' . a:type .' found')
    else
      let l:list = map(l:list, 's:format_symbol_entry(v:val)')

      call s:fzf(a:type, l:list, a:fullscreen)
    endif
endfunction

function! fzf#lsp#implementation(fullscreen, ...) abort
    let l:ctx = { 'fullscreen': a:fullscreen }
    if a:0
        let l:ctx['mods'] = a:1
    endif
    call s:list_location('implementation', l:ctx)
endfunction

function! fzf#lsp#type_definition(fullscreen, ...) abort
    let l:ctx = { 'fullscreen': a:fullscreen }
    if a:0
        let l:ctx['mods'] = a:1
    endif
    call s:list_location('typeDefinition', l:ctx)
endfunction


function! fzf#lsp#declaration(fullscreen, ...) abort
    let l:ctx = { 'fullscreen': a:fullscreen }
    if a:0
        let l:ctx['mods'] = a:1
    endif
    call s:list_location('declaration', l:ctx)
endfunction

function! fzf#lsp#definition(fullscreen, ...) abort
    let l:ctx = { 'fullscreen': a:fullscreen }
    if a:0
        let l:ctx['mods'] = a:1
    endif
    call s:list_location('definition', l:ctx)
endfunction

function! fzf#lsp#references(fullscreen) abort
    let l:ctx = { 'fullscreen': a:fullscreen, 'jump_if_one': 0 }
    let l:request_params = { 'context': { 'includeDeclaration': v:false } }
    call s:list_location('references', l:ctx, l:request_params)
endfunction

function! s:list_location(method, ctx, ...) abort
    " typeDefinition => type definition
    let l:operation = substitute(a:method, '\u', ' \l\0', 'g')

    let l:capabilities_func = printf('lsp#capabilities#has_%s_provider(v:val)', substitute(l:operation, ' ', '_', 'g'))
    let l:servers = filter(lsp#get_allowed_servers(), l:capabilities_func)
    let l:command_id = lsp#_new_command()


    let l:ctx = extend({ 'counter': len(l:servers), 'list':[], 'last_command_id': l:command_id, 'jump_if_one': 1, 'mods': '', 'fullscreen': 0}, a:ctx)
    if len(l:servers) == 0
        call s:not_supported('Retrieving ' . l:operation)
        return
    endif

    let l:params = {
        \   'textDocument': lsp#get_text_document_identifier(),
        \   'position': lsp#get_position(),
        \ }
    if a:0
        call extend(l:params, a:1)
    endif
    for l:server in l:servers
        call lsp#send_request(l:server, {
            \ 'method': 'textDocument/' . a:method,
            \ 'params': l:params,
            \ 'on_notification': function('s:handle_location', [l:ctx, l:server, l:operation]),
            \ })
    endfor

    echo printf('Retrieving %s ...', l:operation)
endfunction

" val = {
"   'filename',
"   'lnum',
"   'col',
"   'text',
"   'viewstart?',
"   'viewend?',
" }
function! s:format_location_entry(val) abort
  let l:filename = printf('%s%s%s', s:ansi.purple, fnamemodify(a:val.filename, ':~:.'), s:ansi.reset)
  let l:lnum = printf('%s%s%s', s:ansi.green, a:val.lnum, s:ansi.reset)
  let l:col = a:val.col
  let l:text = a:val.text

  return printf('%s:%s:%s: %s', l:filename, l:lnum, l:col, l:text)
endfunction

function! s:handle_location(ctx, server, type, data) abort "ctx = {counter, list, last_command_id, jump_if_one, mods}
    if a:ctx['last_command_id'] != lsp#_last_command()
      return
    endif

    let a:ctx['counter'] = a:ctx['counter'] - 1

    if lsp#client#is_error(a:data['response']) || !has_key(a:data['response'], 'result')
      call lsp#utils#error('Failed to retrieve '. a:type . ' for ' . a:server . ': ' . lsp#client#error_message(a:data['response']))
    else
      let a:ctx['list'] = a:ctx['list'] + lsp#utils#location#_lsp_to_vim_list(a:data['response']['result'])
    endif

    if a:ctx['counter'] == 0
      if empty(a:ctx['list'])
        call lsp#utils#error('No ' . a:type .' found')
      else
        call lsp#utils#tagstack#_update()

        let l:loc = a:ctx['list'][0]

        if len(a:ctx['list']) == 1 && a:ctx['jump_if_one']
          call lsp#utils#location#_open_vim_list_item(l:loc, a:ctx['mods'])
          echo 'Retrieved ' . a:type
          redraw
        else
          let l:list = map(a:ctx['list'], 's:format_location_entry(v:val)')
          call s:fzf(a:type, l:list, a:ctx['fullscreen'])
        endif
      endif
    endif
endfunction
