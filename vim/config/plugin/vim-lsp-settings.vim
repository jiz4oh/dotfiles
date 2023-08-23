let g:lsp_settings_filetype_ruby = ['ruby-lsp', 'solargraph']
let g:lsp_settings_deny_local_keys = []

if exists('g:project_markers')
  let g:lsp_settings_root_markers = g:project_markers
end
