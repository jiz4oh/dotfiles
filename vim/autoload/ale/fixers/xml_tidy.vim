call ale#Set('html_tidy_executable', 'tidy')
call ale#Set('html_tidy_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale#fixers#xml_tidy#Fix(buffer) abort
    let l:executable = ale#path#FindExecutable(
    \   a:buffer,
    \   'html_tidy',
    \   ['tidy'],
    \)

    if !executable(l:executable)
        return 0
    endif

    let l:config = ale#path#FindNearestFile(a:buffer, '.tidyrc')
    let l:config_options = !empty(l:config)
    \   ? ' -xml -i -w 0 -q -config ' . ale#Escape(l:config)
    \   : ' -xml -i -w 0 -q'

    return {
    \   'command': ale#Escape(l:executable) . l:config_options,
    \}
endfunction
