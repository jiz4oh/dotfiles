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

silent! if plug#begin(get(g:, 'config_home', '~/.vim') . '/bundle')
set updatetime=100
if executable('mise')
  Plug 'jiz4oh/mise.vim'
elseif executable('asdf')
  Plug 'jiz4oh/direnv.vim'
  Plug 'jiz4oh/asdf.vim'
end
  
" Plug 'tpope/vim-rbenv'
" ============================================================================
" NAVIGATION / MOVE / Easier READ {{{
" ============================================================================
Plug 'christoomey/vim-tmux-navigator'
" https://github.com/easymotion/vim-easymotion
Plug 'easymotion/vim-easymotion', { 'on': ['<Plug>(easymotion-prefix)', '<Plug>(easymotion-bd-jk)', '<Plug>(easymotion-overwin-line)'] }

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } |
     \ Plug 'junegunn/fzf.vim'

Plug 'tracyone/fzf-funky'

Plug 'preservim/nerdtree', { 'on': ['NERDTree', 'NERDTreeVCS', 'NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'for': 'NERDTree' }
Plug 'PhilRunninger/nerdtree-visual-selection', { 'for': 'NERDTree' }
if has('nvim')
  Plug 'nvimdev/indentmini.nvim'
endif
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
" Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() } }

if v:version >= 704
  Plug 'mzlogin/vim-markdown-toc', { 'on': ['GenTocGFM', 'UpdateToc'] }
endif

" markdown preview
if v:version >= 800 && get(g:, 'as_ide', 0)
  Plug 'iamcco/markdown-preview.nvim', { 'do': ':call mkdp#util#install()' }
endif
Plug 'ferrine/md-img-paste.vim', { 'for': 'markdown' }
Plug 'jiz4oh/vim-upgit', { 'do': './install' }
" }}}

" ============================================================================
" DATABASE {{{
" ============================================================================
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'kristijanhusak/vim-dadbod-completion'
" }}}
"
" ============================================================================
" REPL / BUILD / COMPILE {{{
" ============================================================================
" Plug 'axvr/zepl.vim'
Plug 'tpope/vim-dispatch'
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/asynctasks.vim'
" search compiler from
" :e $VIMRUNTIME/compiler
" https://github.com/search?p=1&q=current_compiler++NOT+Maintainer+extension%3Avim+path%3Acompiler%2F+language%3A%22Vim+script%22&type=Code
Plug 'drgarcia1986/python-compilers.vim'
Plug 'jpalardy/vim-slime'
Plug 'vim-test/vim-test'
" }}}

" ============================================================================
" FILETYPE {{{
" ============================================================================
if has('nvim')
  Plug 'nathom/filetype.nvim'
endif
Plug 'sheerun/vim-polyglot'
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

if g:as_ide && has('nvim-0.8')
  Plug 'nvim-lua/plenary.nvim'
  Plug 'pmizio/typescript-tools.nvim'
endif
" }}}

" ============================================================================
" TEXT OBJECTS {{{
" ============================================================================
Plug 'wellle/targets.vim'
Plug 'michaeljsmith/vim-indent-object'
Plug 'kana/vim-textobj-user'
Plug 'jeremiahkellick/vim-textobj-rubyblock', { 'for': 'ruby' }
Plug 'adriaanzon/vim-textobj-matchit'
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
if executable('pipx')
  Plug 'Vimjas/vint', { 'on': 'Ajksdhfas', 'do': 'pipx install .' } " just install vint by vim-plug, do not load it
endif
if executable('npm')
  Plug 'rhysd/fixjson', { 'on': 'Ajksdhfas', 'do': 'npm install . && npm link && npm install -g fixjson' }
endif
if has('timers') && (has('nvim-0.2.0') || exists('*job_start') && exists('*ch_close_in'))
  Plug 'dense-analysis/ale'
  Plug 'jiz4oh/ale-autocorrect.vim'
endif
if has('nvim-0.6')
  Plug 'dgagn/diagflow.nvim'
endif

"lsp
if g:as_ide
  if has('nvim-0.8')
    Plug 'williamboman/mason.nvim' 
    Plug 'williamboman/mason-lspconfig.nvim'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'neovim/nvim-lspconfig'
    "fzf integration
    "https://github.com/ojroques/nvim-lspfuzzy
    Plug 'ojroques/nvim-lspfuzzy'
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
  if has('nvim')
    Plug 'zbirenbaum/copilot.lua'
    Plug 'zbirenbaum/copilot-cmp'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'nvim-lua/plenary.nvim'
    if has('nvim-0.9.5')
      Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
    endif
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'f3fora/cmp-spell'
    if exists('$KITTY_WINDOW_ID')
      Plug 'garyhurtz/cmp_kitty'
    endif
    Plug 'roobert/tailwindcss-colorizer-cmp.nvim'

    if executable('ctags')
      Plug 'quangnguyen30192/cmp-nvim-tags'
    endif

    Plug 'tzachar/cmp-tabnine', { 'do': g:is_win ? 'powershell.exe .\install.ps1' : './install.sh' }
  elseif has('patch-9.0.0185') && executable('node')
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
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
  
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-surround'
" neovim 0.10.0 has native commentary like comment support
" https://neovim.io/doc/user/various.html#commenting
if !has('nvim-0.10.0')
  Plug 'tpope/vim-commentary'
end
Plug 'tpope/vim-endwise'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'junegunn/vim-easy-align'
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
" Plug 'AndrewRadev/splitjoin.vim'
" }}}

" ============================================================================
" Utils {{{
" ============================================================================
Plug 'tpope/vim-eunuch'
" Plug 'jiz4oh/vim-terminal-help'
Plug 'voldikss/vim-floaterm'
if g:as_ide
  Plug 'tpope/vim-scriptease'
  Plug 'tweekmonster/helpful.vim', { 'on': 'HelpfulVersion' }
end
Plug 'mhinz/vim-hugefile'
Plug 'pbogut/fzf-mru.vim'
Plug 'liuchengxu/vim-which-key'
Plug 'ojroques/vim-oscyank'
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
Plug 'tyru/open-browser.vim'
Plug 'vim-utils/vim-man'
Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'tpope/vim-repeat'
if !has('nvim') && exists('##TextYankPost')
  Plug 'machakann/vim-highlightedyank'
end
Plug 'markonm/traces.vim'
Plug 'junegunn/vim-peekaboo'
Plug 'haya14busa/vim-asterisk', { 'on': ['<Plug>(asterisk-z*)', '<Plug>(asterisk-z#)', '<Plug>(asterisk-gz*)', '<Plug>(asterisk-gz#)'] }
Plug 'troydm/zoomwintab.vim'
" }}}

" ============================================================================
" BEAUTIFY {{{
" ============================================================================
if g:as_ide
  if has('nvim')
    Plug 'rcarriga/nvim-notify'
    Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
    if has('nvim-0.9')
      Plug 'stevearc/aerial.nvim'
    endif
  endif
  if has('nvim') || has('gui_running')
    " Plug 'vim-airline/vim-airline'
  endif
  Plug 'junegunn/rainbow_parentheses.vim'
  Plug 'vim/killersheep'

  if get(g:, 'enable_nerd_font', 0)
    Plug 'ryanoasis/vim-devicons'
  endif
endif
Plug 'sainnhe/gruvbox-material'
Plug 'sainnhe/everforest'
Plug 'sainnhe/edge'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'uguu-org/vim-matrix-screensaver'
"}}}
call plug#end()
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

if g:as_ide
  silent! colorscheme gruvbox-material
endif
