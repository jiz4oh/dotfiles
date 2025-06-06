" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://cdn.jsdelivr.net/gh/junegunn/vim-plug@master/plug.vim
endif

"Run PlugInstall if there are missing plugins
"autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  "\| PlugInstall --sync | source $MYVIMRC
"\| endif

if exists(':packadd')
  silent! packadd! matchit
  " if has("patch-8.1.0311")
  "   silent! packadd! cfilter
  " endif
else
  runtime macros/matchit.vim
endif

let g:as_ide = get(g:, 'as_ide', 0)

silent! if plug#begin()
set updatetime=100
if executable('mise')
  Plug 'jiz4oh/mise.vim'
elseif executable('asdf')
  Plug 'jiz4oh/direnv.vim'
  Plug 'jiz4oh/asdf.vim'
end

function! MyLoad(name) abort
  if get(g:, 'loaded_lazy')
    "try
      execute 'lua require("lazy").load({ plugins = { "' . a:name . '" } })'
    "catch
    "endtry
  else
    call plug#load(a:name)
  end
endfunction

let g:with_treesitter = g:as_ide && has('nvim-0.9.2')
" Plug 'tpope/vim-rbenv'
" ============================================================================
" NAVIGATION / MOVE / Easier READ {{{
" ============================================================================
Plug 'christoomey/vim-tmux-navigator'
" https://github.com/easymotion/vim-easymotion
Plug 'easymotion/vim-easymotion', { 'on': ['<Plug>(easymotion-prefix)', '<Plug>(easymotion-bd-jk)', '<Plug>(easymotion-overwin-line)'] }

Plug 'junegunn/fzf', { 'do': ':call fzf#install()' } |
     \ Plug 'junegunn/fzf.vim'

Plug 'tracyone/fzf-funky'

Plug 'preservim/nerdtree', { 'on': ['NERDTree', 'NERDTreeVCS', 'NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'for': 'NERDTree' }
Plug 'PhilRunninger/nerdtree-visual-selection', { 'for': 'NERDTree' }
" isn't compatible with easymotion
"if has('nvim')
"  Plug 'nvimdev/indentmini.nvim'
"endif
" }}}

" ============================================================================
" VCS / PROJECT {{{
" ============================================================================
Plug 'tpope/vim-projectionist'
" Plug 'airblade/vim-rooter'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
" Plug 'junegunn/gv.vim', { 'on': ['GV', 'GV!'] }

if has('nvim') || executable('luajit')
  Plug 'rbong/vim-flog'
else
  Plug 'rbong/vim-flog', { 'branch': 'v1' }
end
" if v:version >= 800
"   Plug 'rhysd/git-messenger.vim'
" endif
" }}}

" ============================================================================
" DOCUMENT / MARKDOWN {{{
" ============================================================================
Plug 'lervag/wiki.vim'
" Plug 'kkoomen/vim-doge', { 'do': ':call doge#install()' }

if v:version >= 704
  Plug 'mzlogin/vim-markdown-toc', { 'on': ['GenTocGFM', 'UpdateToc'] }
endif

" markdown preview
if v:version >= 800 && get(g:, 'as_ide', 0)
  Plug 'iamcco/markdown-preview.nvim', { 'do': ':call mkdp#util#install()' }
endif
Plug 'ferrine/md-img-paste.vim', { 'for': 'markdown' }
Plug 'jiz4oh/vim-upgit', { 'do': './install' }
Plug 'qadzek/link.vim'
" }}}

" ============================================================================
" DATABASE {{{
" ============================================================================
Plug 'tpope/vim-dadbod', { 'on': ['DB'] }
Plug 'kristijanhusak/vim-dadbod-ui', { 'on': ['DBUI', 'DBUIToggle'], 'for': 'dbui' }
Plug 'kristijanhusak/vim-dadbod-completion', { 'for': ['sql', 'mysql', 'plsql'] }
" }}}
"
" ============================================================================
" REPL / BUILD / COMPILE {{{
" ============================================================================
" Plug 'axvr/zepl.vim'
Plug 'tpope/vim-dispatch'
"Plug 'skywind3000/asyncrun.vim'
"Plug 'skywind3000/asynctasks.vim'
" search compiler from
" :e $VIMRUNTIME/compiler
" https://github.com/search?p=1&q=current_compiler++NOT+Maintainer+extension%3Avim+path%3Acompiler%2F+language%3A%22Vim+script%22&type=Code
Plug 'drgarcia1986/python-compilers.vim'
Plug 'jpalardy/vim-slime'
Plug 'vim-test/vim-test', { 'on': ['TestNearest', 'TestFile', 'TestSuite', 'TestLast', 'TestVisit'] }
" }}}

" ============================================================================
" FILETYPE {{{
" ============================================================================
if has('nvim') && !has('nvim-0.7')
  Plug 'nathom/filetype.nvim'
endif
if !has('nvim-0.9')
  Plug 'sheerun/vim-polyglot'
else
  Plug 'bfontaine/Brewfile.vim'
  Plug 'MTDL9/vim-log-highlighting'
end
Plug 'fladson/vim-kitty'
Plug 'craigmac/vim-mermaid'
Plug 'hallison/vim-rdoc'
if executable('plutil')
  Plug 'darfink/vim-plist'
endif
if executable('bundle')
  Plug 'tpope/vim-bundler'
endif
Plug 'tpope/vim-rails'
" Plug 'vlime/vlime', {'rtp': 'vim/'}
" Plug 'kovisoft/paredit', { 'for': ['clojure', 'scheme'] }
if has('nvim') || has('patch-8.0.1453')
  Plug 'fatih/vim-go'
endif
Plug 'mityu/vim-applescript'

" }}}

" ============================================================================
" TEXT OBJECTS {{{
" ============================================================================
Plug 'wellle/targets.vim'
Plug 'michaeljsmith/vim-indent-object'
Plug 'kana/vim-textobj-user'
Plug 'jeremiahkellick/vim-textobj-rubyblock', { 'for': 'ruby' }
Plug 'adriaanzon/vim-textobj-matchit', { 'for': ['ruby', 'vim', 'tex', 'blade', 'lua'] }
Plug 'whatyouhide/vim-textobj-erb', { 'for': 'eruby' }
" }}}

" ============================================================================
" TAGS {{{
" ============================================================================
if executable('ctags')
  Plug 'ludovicchabant/vim-gutentags'
  if has('patch-7.3.1058')
    Plug 'preservim/tagbar', { 'on': 'TagbarToggle' }
  endif
endif

if g:as_ide || executable('ctags')
  Plug 'liuchengxu/vista.vim'
endif
"}}}

" ============================================================================
" Easier EDIT {{{
" ============================================================================
Plug 'ahonn/vim-fileheader'
if has('timers') && (has('nvim-0.2.0') || exists('*job_start') && exists('*ch_close_in'))
  Plug 'dense-analysis/ale'
  Plug 'jiz4oh/ale-autocorrect.vim'
endif
"if has('nvim-0.6')
"  Plug 'dgagn/diagflow.nvim'
"endif
if has('nvim-0.10')
  "Plug 'rachartier/tiny-inline-diagnostic.nvim'
endif

"lsp
if g:as_ide
  if has('nvim-0.8')
    if has('nvim-0.9.4')
      "TextChanged event is too slow
      "Plug 'maxandron/goplements.nvim'
    endif
  else
    "https://github.com/prabirshrestha/vim-lsp/issues/1492
    Plug 'prabirshrestha/vim-lsp'
    Plug 'jiz4oh/vim-lspfuzzy'
    Plug 'rhysd/vim-lsp-ale'
    Plug 'mattn/vim-lsp-settings'
    Plug 'dmitmel/cmp-vim-lsp'
   endif
endif

"autocomplete
if g:as_ide
  if has('patch-9.0.0185') && executable('node')
    Plug 'github/copilot.vim'
  " elseif v:version >= 800
    " Plug 'lifepillar/vim-mucomplete'
    " autocomplete
    " Plug 'prabirshrestha/asyncomplete.vim'
    " Plug 'machakann/asyncomplete-ezfilter.vim'
    " Plug 'prabirshrestha/asyncomplete-buffer.vim'
    " Plug 'prabirshrestha/asyncomplete-file.vim'

    " if executable('ctags')
    "   Plug 'prabirshrestha/asyncomplete-tags.vim'
    " endif

    " Plug 'kitagry/asyncomplete-tabnine.vim', { 'do': g:is_win ? 'powershell.exe .\install.ps1' : './install.sh' }
  endif
else
  Plug 'skywind3000/vim-auto-popmenu'
endif

if executable('node')
  " Plug 'Shougo/neco-vim'
  " Plug 'neoclide/coc-neco'
  " Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
  
Plug 'mattn/emmet-vim', { 'on': 'EmmetInstall', 'for': ['html', 'css', 'eruby', 'xml'] }
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-surround'
" neovim 0.10.0 has native commentary like comment support
" https://neovim.io/doc/user/various.html#commenting
if !has('nvim-0.10.0')
  Plug 'tpope/vim-commentary'
end
if !g:with_treesitter
  " endwise based on vim syntax group and is not compatible with nvim-treesitter 
  Plug 'tpope/vim-endwise'
end
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'junegunn/vim-easy-align'
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
" Plug 'AndrewRadev/splitjoin.vim'
" }}}

" ============================================================================
" Utils {{{
" ============================================================================
Plug 'lambdalisue/vim-suda'
Plug 'tpope/vim-eunuch'
" Plug 'jiz4oh/vim-terminal-help'
Plug 'voldikss/vim-floaterm'
if g:as_ide
  Plug 'tpope/vim-scriptease'
  Plug 'tweekmonster/helpful.vim', { 'on': 'HelpfulVersion' }
end
Plug 'mhinz/vim-hugefile'
Plug 'pbogut/fzf-mru.vim'
if !has('nvim-0.10')
  Plug 'liuchengxu/vim-which-key'
end
if exists('$SSH_TTY') && !has('nvim-0.10')
  Plug 'ojroques/vim-oscyank'
endif
Plug 'skywind3000/vim-dict'
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }
Plug 'justinmk/vim-gtfo'
Plug 'mhinz/vim-startify'
Plug 'dstein64/vim-startuptime', {'on':'StartupTime'}

Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-apathy'
Plug 'AndrewRadev/undoquit.vim'
Plug 'kristijanhusak/vim-carbon-now-sh'
Plug 'junegunn/vader.vim'
if !has('nvim')
  Plug 'rhysd/vim-healthcheck'
endif
" Plug 'romainl/vim-qf'
" }}}

" ============================================================================
" Butil-in Enhance {{{
" ============================================================================
" Plug 'andymass/vim-matchup'
Plug 'ypcrts/securemodelines'
"https://github.com/neovim/neovim/commit/af6e6ccf3dee815850639ec5613dda3442caa7d6
if !has('nvim-0.10')
  Plug 'tyru/open-browser.vim'
end
Plug 'vim-utils/vim-man'
Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'tpope/vim-repeat'
if !has('nvim') && exists('##TextYankPost')
  Plug 'machakann/vim-highlightedyank'
end
Plug 'markonm/traces.vim'
" replace by which-key.nvim
if !has('nvim-0.10')
  Plug 'junegunn/vim-peekaboo'
end
Plug 'haya14busa/vim-asterisk'
Plug 'troydm/zoomwintab.vim'

"https://github.com/tmux-plugins/vim-tmux-focus-events?tab=readme-ov-file#tmux-focus-eventsvim
if has('patch-8.2.2345') || has('nvim')
  Plug 'roxma/vim-tmux-clipboard'
endif
" }}}

" ============================================================================
" BEAUTIFY {{{
" ============================================================================
if g:as_ide
  if has('nvim') || has('gui_running')
    " Plug 'vim-airline/vim-airline'
  endif
  Plug 'junegunn/rainbow_parentheses.vim'
  Plug 'vim/killersheep'

  if get(g:, 'enable_nerd_font', 0)
    Plug 'ryanoasis/vim-devicons'
  endif

  Plug 'sainnhe/gruvbox-material'
  Plug 'sainnhe/everforest'
  Plug 'sainnhe/edge'
  Plug 'rafi/awesome-vim-colorschemes'
endif
Plug 'uguu-org/vim-matrix-screensaver'
"}}}
if has('nvim-0.8')
  let g:loaded_lazy = 1
  execute 'luafile '. expand('<sfile>:p:h') . '/plugin.lua'
else
  call plug#end()

  augroup PlugLazyLoad
    autocmd!

    if exists('g:plugs_order')
      for plugName in g:plugs_order
        if HasInstall(plugName)
          let spec = g:plugs[plugName]
          "TODO plug.vim 内部判断某个插件是否 lazy，不只是判断是否有 on 或者 for
          " if has_key(spec, 'on') || has_key(spec, 'for')
          "   execute 'autocmd User ' . plugName . ' call SourceConfig("plugin/' . plugName . '")'
          " else
            call SourceConfig('plugin/' . plugName)
          " endif
        endif
      endfor
    endif
  augroup END
end
endif

function! s:plug_gf() abort
  let line = getline(line('.'))
  let repo = substitute(substitute(matchstr(line, "Plug\\s*['\"][^'\"]*['\"]"), "['\"]", '', 'g'), 'Plug\s*' , '', 'g')
  let plug_name = fnamemodify(repo, ':t:s?\.git$??')
  if !empty(plug_name)
    let path = expand('%:p:h') . '/plugin/' . plug_name .'.vim'
    execute 'e ' . path
  else
    normal! gf
  end
endfunction

augroup vim-plug-augroup
  autocmd!

  execute 'autocmd BufEnter '. expand('<sfile>:p') . ' nnoremap <buffer><silent> gf :call <SID>plug_gf()<cr>'
augroup END
