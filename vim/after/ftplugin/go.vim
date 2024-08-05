if exists('*apathy#Prepend')
  call apathy#Prepend('path', map(apathy#Split(
        \ len($GOPATH) ? apathy#EnvSplit($GOPATH) : expand('~/go')),
        \ 'v:val . "/pkg/mod"'))
endif
