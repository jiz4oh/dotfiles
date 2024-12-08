if has('nvim-0.7.0')
  finish
end

autocmd BufRead,BufNewFile *.http set filetype=http
