" https://github.com/tpope/vim-apathy/blob/27128a0f55189724c841843ba41cd33cf7186032/after/ftplugin/python_apathy.vim

if exists('g:python_path')
  let path = g:python_path
else
  let path = split(system(get(g:, 'python_executable', 'python') . ' -c "import sys; print(''\n''.join(sys.path))"')[0:-2], "\n", 1)
endif

let path = filter(path, '!empty(v:val)')
let path = map(path, 'v:val . "/tags"')
let path = join(path, ',')

exec 'setlocal tags+=' . path
