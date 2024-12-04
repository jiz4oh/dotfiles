function! select#package#call(filetype, opts)
  let packages = function('select#packages#'.a:filetype.'#packages')()
  let prompt = function('select#packages#'.a:filetype.'#prompt')()

  let l:opts = extend({
        \'packages': packages,
        \'prompt': prompt,
        \}, a:opts, 'keep')

  call select#provider#fzf#packages(l:opts)
endfunction

function! select#package#filetypes()
  return [
        \'ruby',
        \'go',
        \'vim',
        \'javascript',
        \]
endfunction
