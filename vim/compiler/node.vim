" Vim compiler file

if exists("current_compiler")
  finish
endif

" https://github.com/felixge/vim-nodejs-errorformat/blob/master/ftplugin/javascript.vim

" Error: bar
"     at Object.foo [as _onTimeout] (/Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2:9)
let errorformat  = '%+A%.%#Error: %m' . ','
let errorformat .= '%Z%*[\ ]at\ %f:%l:%c' . ','
let errorformat .= '%Z%*[\ ]%m (%f:%l:%c)' . ','

"     at Object.foo [as _onTimeout] (/Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2:9)
let errorformat .= '%*[\ ]%m (%f:%l:%c)' . ','

"     at node.js:903:3
let errorformat .= '%*[\ ]at\ %f:%l:%c' . ','

" /Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2
"   throw new Error('bar');
"         ^
let errorformat .= '%Z%p^,%A%f:%l,%C%m' . ','

" Ignore everything else
let errorformat .= '%-G%.%#'

CompilerSet makeprg=node\ %
execute 'CompilerSet errorformat=' . errorformat

let current_compiler = "node"
