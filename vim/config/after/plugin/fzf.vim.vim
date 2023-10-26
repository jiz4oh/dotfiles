command! -nargs=? -bang FzfLspReferences      call fzf#lsp#references(<bang>0, {'jump_if_one': 1})
nnoremap <silent> <plug>(lsp-document-symbol-search) :<c-u>FzfLspDocumentSymbol<cr>
nnoremap <silent> <plug>(lsp-workspace-symbol-search) :<c-u>FzfLspWorkspaceSymbol<cr>
xnoremap <silent> <plug>(lsp-workspace-symbol-search) :<c-u>execute ':FzfLspWorkspaceSymbol '.personal#functions#selected()<cr>
nnoremap <silent> <plug>(lsp-definition) :<c-u>FzfLspDefintion<cr>
nnoremap <silent> <plug>(lsp-declaration) :<c-u>FzfLspDeclaration<cr>
nnoremap <silent> <plug>(lsp-type-definition) :<c-u>FzfLspTypeDefinition<cr>
nnoremap <silent> <plug>(lsp-implementation) :<c-u>FzfLspImplementation<cr>
nnoremap <silent> <plug>(lsp-references) :<c-u>FzfLspReferences<cr>
