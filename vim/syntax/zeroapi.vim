" zeroapi: Vim syntax file
" Language:             Go/go-zero
" Maintainer:           Billie Cleek <bhcleek@gmail.com>, jiz4oh <me@jiz4oh.com>
" Latest Revision:      2024-03-07
" License:              BSD-style. See LICENSE file in source repository.
" Repository:           https://github.com/fatih/vim-go

" inspired by https://github.com/zeromicro/goctl-vscode/blob/main/syntaxes/goctl.tmLanguage.json
if exists('b:current_syntax')
    finish
endif

let s:keepcpo = &cpo
set cpo&vim

runtime syntax/go.vim

"{{{ go-zero
syn keyword zeroSyntax             syntax
syn keyword zeroServiceDeclaration service
syn keyword zeroServiceMethod      HEAD GET POST PUT PATCH DELETE CONNECT OPTIONS TRACE head get post put patch delete connect options trace
syn match   zeroServiceHandler     /@handler/
syn match   zeroServiceServer      /@server/

hi def link     zeroSyntax             Statement
hi def link     zeroServiceDeclaration Keyword
hi def link     zeroServiceMethod      Function
hi def link     zeroServiceHandler     Function
hi def link     zeroServiceServer      Function
"}}}

let b:current_syntax = 'zeroapi'

let &cpo = s:keepcpo
unlet s:keepcpo
