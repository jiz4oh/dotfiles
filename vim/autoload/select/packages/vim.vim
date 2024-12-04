function! s:split_rtp()
  return split(&runtimepath, '\\\@<!,')
endfunction

function! select#packages#vim#prompt() abort
  return 'Plugin'
endfunction

function! select#packages#vim#packages() abort
  let res = {
        \'$VIMRUNTIME': $VIMRUNTIME,
        \}

  if &loadplugins
    let rtp = s:split_rtp()
    let rtp = filter(rtp, 'v:val !~# "after"')

    for path in rtp
      if isdirectory(path)
        let res[fnamemodify(path, ':p:h')] = path
      endif
    endfor
  endif

  for [plugin, dir] in items(s:lazy_integrate())
    let res[plugin] = dir
  endfor

  return res
endfunction

function! s:lazy_integrate() abort
  let res = {}
  " lazy.vim did not respected the runtimepath
  " https://lazy.folke.io/usage#%EF%B8%8F-startup-sequence
  try
lua<<EOF

local res = {}
vim.tbl_map(function(v)
  res[v['name']] = v['dir']
end, require('lazy.core.config').plugins)
vim.g.___lazy_plugins = res
EOF

    let loaded_lazy = 1
  catch
    let loaded_lazy = 0
  endtry

  if loaded_lazy
    for [plugin, dir] in items(g:___lazy_plugins)
      let res[plugin] = dir
    endfor
  end

  return res
endfunction
