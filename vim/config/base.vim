" do not open fullscreen in macos, it is conflict with some plugins
" let g:neovide_fullscreen= 1
let $DISABLE_PRY_PAGER = 1
let g:is_darwin = get(g:, 'is_darwin', has('mac'))
let g:is_win    = get(g:, 'is_win', has('win32') || has('win64'))

" leader
let mapleader      = ' '
let maplocalleader = ' '
let g:mapleader    = ' '

" syntax
syntax on
syntax enable

" filetype
filetype on
" Enable filetype plugins
filetype plugin on
filetype indent on

" base
set nocompatible                " don't bother with vi compatibility
set autoread                    " reload files when changed on disk, i.e. via `git checkout`
set shortmess=atIF
set shortmess+=A                " this is needed to avoid swapfile warning when auto-reloading

set shortmess+=I                " Don't display the intro message on starting Vim.

set magic                       " For regular expressions turn magic on
set title                       " change the terminal's title
set hidden                      " donot hidden after disable terminal
set splitbelow                  " split a window one the below
set splitright                  " vsplit a window on the right
set exrc

set spell
set spelllang=en_us,cjk
set spellsuggest=best,9

set history=2000                " how many lines of history VIM has to remember

if has('vim_starting') && exists('+undofile')
  set undofile
endif

if v:version >= 700
  set viminfo=!,'20,<50,s10,h
endif
if !empty($SUDO_USER) && $USER !=# $SUDO_USER
  set viminfo=
  set directory-=~/tmp
  set backupdir-=~/tmp
elseif exists('+undodir') && !has('nvim-0.5')
  if !empty($XDG_DATA_HOME)
    let s:data_home = substitute($XDG_DATA_HOME, '/$', '', '') . '/vim/'
  elseif g:is_win
    let s:data_home = expand('~/AppData/Local/vim/')
  else
    let s:data_home = expand('~/.local/share/vim/')
  endif
  let &undodir = s:data_home . 'undo//'
  let &directory = s:data_home . 'swap//'
  let &backupdir = s:data_home . 'backup//'
  " automatically create directories for backup, undo files.
  if !isdirectory(expand(s:data_home))
    call system("mkdir -p " . expand(s:data_home) . "/{backup,undo,swap}")
  end
endif

set novisualbell                " turn off visual bell
set noerrorbells                " don't beep
set visualbell t_vb=            " turn off error beep/flash
set t_RV=
set tm=500

" fix issues with fish shell
" https://github.com/tpope/vim-sensible/issues/50
if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
  set shell=/usr/bin/env\ bash
endif

set tabpagemax=50               " allow for up to 50 opened tabs on Vim start.
" movement
set scrolloff=1                 " keep 1 lines when scrolling
set sidescrolloff=5             " keep 5 columns next to the cursor when scrolling horizontally.

" show
set ruler                       " show the current row and column
set showcmd                     " display incomplete commands
set noshowmode                  " do not display current modes
set showmatch                   " jump to matches when entering parentheses
set matchtime=2                 " tenths of a second to show the matching parenthesis
set display+=lastline           " when 'wrap' is on, display last line even if it doesn't fit.

" wrap lines by default
set wrap linebreak
set showbreak=" "

" search
set hlsearch                    " highlight searches
set incsearch                   " do incremental searching, search as you type
set ignorecase                  " ignore case when searching
set smartcase                   " no ignorecase if Uppercase char present

" tab
set expandtab                   " expand tabs to spaces
set smarttab
set shiftround

" indent
set autoindent smartindent shiftround
set shiftwidth=2                " auto indent use 2 spaces
set tabstop=2                   " insert mode tab use 2 spaces
set softtabstop=2               " insert mode <Tab> use 2 spaces

" fold
if has('vim_starting')
  set foldmethod=marker
  set foldnestmax=3
  set foldopen+=jump
  set foldlevel=1
  set commentstring=#\ %s
endif

" encoding
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gb2312,gbk,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set termencoding=utf-8
set ffs=unix,dos,mac

if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+  " set default whitespace characters when using `:set list`
endif

if v:version > 703 || v:version == 703 && has("patch541") 
  set formatoptions+=j          " delete comment character when joining commented lines
endif
set formatoptions+=m
set formatoptions+=B

" select & complete
if has('path_extra')
  set tags-=./tags tags-=./tags; tags^=./tags; " search upwards for tags file instead only locally
endif

set tags+=gems.tags             " add gems.tags to files searched for tags.

set complete+=k
if executable('ctags')
  set complete-=i                 " don't scan included files. The .tags file is more performant.
endif
set completeopt=menuone,noinsert,noselect,preview
if has('textprop') && has('patch-8.1.1880')
  set completeopt+=popup
  set completepopup=height:10,width:60,highlight:InfoPopup
endif
set selection=inclusive
set selectmode=mouse,key

set wildmenu                           " show a navigable menu for tab completion"
set wildmode=longest,full
if has('patch-8.2.4325')
  set wildoptions=pum
endif
if v:version >= 900
  set wildoptions+=fuzzy
endif
" 文件搜索和补全时忽略下面的扩展名
set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.pyc,.pyo,.egg-info,.class
"stuff to ignore when tab completing
set wildignore=*.o,*.obj,*~,*.exe,*.a,*.pdb,*.lib
set wildignore+=*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex
set wildignore+=tags,.*.un~
" MacOSX/Linux
set wildignore+=*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz
set wildignore+=*DS_Store*,*.ipch
set wildignore+=*.gem
set wildignore+=*.png,*.jpg,*.gif,*.bmp,*.tga,*.pcx,*.ppm,*.img,*.iso
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg
set wildignore+=*/.nx/**,*.app,*.git,.git
set wildignore+=*.wav,*.mp3,*.ogg,*.pcm
set wildignore+=*.mht,*.suo,*.sdf,*.jnlp
set wildignore+=*.chm,*.epub,*.pdf,*.mobi,*.ttf
set wildignore+=*.mp4,*.avi,*.flv,*.mov,*.mkv,*.swf,*.swc
set wildignore+=*.ppt,*.pptx,*.docx,*.xlt,*.xls,*.xlsx,*.odt,*.wps
set wildignore+=*.msi,*.crx,*.deb,*.vfd,*.apk,*.ipa,*.bin,*.msu
set wildignore+=*.gba,*.sfc,*.078,*.nds,*.smd,*.smc
set wildignore+=*.linux2,*.win32,*.darwin,*.freebsd,*.linux,*.android
" others
set backspace=indent,eol,start         " make that backspace key work the way it should
set whichwrap+=<,>,h,l
set clipboard+=unnamed
set updatetime=100

" https://vi.stackexchange.com/a/24938
set timeoutlen=1500
set ttimeoutlen=50

set diffopt+=vertical                  " make diff windows vertical
set sessionoptions-=options sessionoptions-=buffers sessionoptions-=folds sessionoptions-=terminal
set viewoptions-=options
if !g:is_win
  set dictionary+=/usr/share/dict/words
endif

" make faster
set ttyfast
" https://github.com/vim/vim/issues/1735#issuecomment-383353563
set synmaxcol=200
if v:version < 800 && &term =~ "xterm.*"
    let &t_ti = &t_ti . "\e[?2004h"
    let &t_te = "\e[?2004l" . &t_te
    function! XTermPasteBegin(ret)
        set pastetoggle=<Esc>[201~
        set paste
        return a:ret
    endfunction
    map <expr> <Esc>[200~ XTermPasteBegin("i")
    imap <expr> <Esc>[200~ XTermPasteBegin("")
    vmap <expr> <Esc>[200~ XTermPasteBegin("c")
    cmap <Esc>[200~ <nop>
    cmap <Esc>[201~ <nop>
endif
" ============================================================================
" UI {{{
" ============================================================================
if has('fullscreen')
  set fullscreen
  set macthinstrokes
  let macvim_skip_cmd_opt_movement = 1
endif

set background=dark
" https://github.com/sainnhe/gruvbox-material/issues/5#issuecomment-729586348
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
if has("gui_running") || has("nvim")
  if has("gui_gtk2")
    set guifont=Luxi\ Mono\ 12
  elseif has("x11")
" Also for GTK 1
    set guifont=*-lucidatypewriter-medium-r-normal-*-*-180-*-*-m-*-*
  elseif has("gui_win32")
    set guifont=Luxi_Mono:h12:cANSI
  elseif g:is_darwin
    set guifont=Hack\ Nerd\ Font:h16
  endif

  set guioptions-=r        " Hide the right scrollbar
  set guioptions-=L        " Hide the left scrollbar
  set guioptions-=T
  set guioptions-=e        " make gui use &tabline
  " No annoying sound on errors
  set noerrorbells
  set novisualbell
  set visualbell t_vb=
endif

" color {{{
  set t_Co=256                           " 指定配色方案是256色
  if has('nvim')
    " https://github.com/neovim/neovim/issues/2897#issuecomment-115464516
    let g:terminal_color_0 = '#4e4e4e'
    let g:terminal_color_1 = '#d68787'
    let g:terminal_color_2 = '#5f865f'
    let g:terminal_color_3 = '#d8af5f'
    let g:terminal_color_4 = '#85add4'
    let g:terminal_color_5 = '#d7afaf'
    let g:terminal_color_6 = '#87afaf'
    let g:terminal_color_7 = '#d0d0d0'
    let g:terminal_color_8 = '#626262'
    let g:terminal_color_9 = '#d75f87'
    let g:terminal_color_10 = '#87af87'
    let g:terminal_color_11 = '#ffd787'
    let g:terminal_color_12 = '#add4fb'
    let g:terminal_color_13 = '#ffafaf'
    let g:terminal_color_14 = '#87d7d7'
    let g:terminal_color_15 = '#e4e4e4'
  else
    let g:terminal_ansi_colors = [
      \ '#4e4e4e', '#d68787', '#5f865f', '#d8af5f',
      \ '#85add4', '#d7afaf', '#87afaf', '#d0d0d0',
      \ '#626262', '#d75f87', '#87af87', '#ffd787',
      \ '#add4fb', '#ffafaf', '#87d7d7', '#e4e4e4']
  endif
  if (empty($TMUX))
    if (has("nvim"))
      "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
      let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    endif
    " https://stackoverflow.com/a/62703167
    " https://github.com/termstandard/colors#checking-for-colorterm
    if ($COLORTERM == 'truecolor' || has('gui_running')) && (has("termguicolors"))
      let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
      let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
      set termguicolors
    endif
  endif
" }}}

" cursor style {{{
  if $TERM_PROGRAM =~# 'iTerm'
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_SR = "\<Esc>]50;CursorShape=2\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
  endif

  " inside tmux
  if exists('$TMUX') && $TERM != 'xterm-kitty'
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
  endif

  " inside neovim
  if has('nvim')
    let $NVIM_TUI_ENABLE_CURSOR_SHAPE=2
  endif

  " inside kitty
  " https://neovim.io/doc/user/vim_diff.html#nvim-removed
  if !has('nvim') && exists('$KITTY_WINDOW_ID')
    " https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim
    " Styled and colored underline support
    let &t_AU = "\e[58:5:%dm"
    let &t_8u = "\e[58:2:%lu:%lu:%lum"
    let &t_Us = "\e[4:2m"
    let &t_Cs = "\e[4:3m"
    let &t_ds = "\e[4:4m"
    let &t_Ds = "\e[4:5m"
    let &t_Ce = "\e[4:0m"
    " Strikethrough
    let &t_Ts = "\e[9m"
    let &t_Te = "\e[29m"
    " Truecolor support
    let &t_8f = "\e[38:2:%lu:%lu:%lum"
    let &t_8b = "\e[48:2:%lu:%lu:%lum"
    let &t_RF = "\e]10;?\e\\"
    let &t_RB = "\e]11;?\e\\"
    " Bracketed paste
    let &t_BE = "\e[?2004h"
    let &t_BD = "\e[?2004l"
    let &t_PS = "\e[200~"
    let &t_PE = "\e[201~"
    " Cursor control
    let &t_RC = "\e[?12$p"
    let &t_SH = "\e[%d q"
    let &t_RS = "\eP$q q\e\\"
    let &t_SI = "\e[5 q"
    let &t_SR = "\e[3 q"
    let &t_EI = "\e[1 q"
    let &t_VS = "\e[?12l"
    " Focus tracking
    let &t_fe = "\e[?1004h"
    let &t_fd = "\e[?1004l"
    try
      execute "set <FocusGained>=\<Esc>[I"
      execute "set <FocusLost>=\<Esc>[O"
    catch
    endtry
    " Window title
    let &t_ST = "\e[22;2t"
    let &t_RT = "\e[23;2t"

    " vim hardcodes background color erase even if the terminfo file does
    " not contain bce. This causes incorrect background rendering when
    " using a color theme with a background color in terminals such as
    " kitty that do not support background color erase.
    let &t_ut=''
  endif
"}}}

" status line
set laststatus=2                       "  Always show the status line - use 2 lines for the status bar
" tabline
set showtabline=2
" }}}

" ============================================================================
" AUTOCMD {{{
" ============================================================================
augroup vimrc
  autocmd!

  " Keep a list of the most recent two tabs.
  let g:tablist = [1, 1]
  autocmd TabLeave * let g:tablist[0] = g:tablist[1] | let g:tablist[1] = tabpagenr()
  " When a tab is closed, return to the most recent tab.
  " The way vim updates tabs, in reality, this means we must return
  " to the second most recent tab.
  autocmd TabClosed * exe "normal " . g:tablist[0] . "gt"

  " Make nvim terminal more like vim terminal, 
  " so we can startinsert automatically in terminal buffer
  if has('nvim')
    autocmd BufWinEnter,WinEnter term://* startinsert
  endif
  " Make directory automatically.
  function! s:mkdir_as_necessary(dir, force) abort
    if &l:buftype ==# '' && !isdirectory(a:dir) &&
          \ (a:force || input(printf('"%s" does not exist. Create? [y/N]',
          \              a:dir)) =~? '^y\%[es]$')
      call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
  endfunction

  autocmd BufWritePre * call s:mkdir_as_necessary(expand('<afile>:p:h'), v:cmdbang)

  " Make the yanked region apparent
  if has('nvim')
    au TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false}
  endif
  " Exit Vim if quickfix is the only window remaining in the only tab.
  autocmd WinEnter * if winnr('$') == 1 && &buftype == "quickfix"|q|endif

   "Close preview window
  if exists('##CompleteDone')
    autocmd CompleteDone * if pumvisible() == 0 | pclose | endif
  else
    autocmd InsertLeave * if !pumvisible() && (!exists('*getcmdwintype') || empty(getcmdwintype())) | pclose | endif
  endif

   "Automatic rename of tmux window
  if exists('$TMUX') && !exists('$NORENAME')
    autocmd BufEnter * if empty(&buftype) | call system('tmux rename-window '.expand('%:t:S')) | endif
    autocmd VimLeave * call system('tmux set-window automatic-rename on')
  endif

  "return where you left last time
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif | normal! zvzz

  " restore session automatically if no file is opened
  " autocmd VimEnter * nested
  "     \ if !argc() && empty(v:this_session) && filereadable('Session.vim') && !&modified |
  "     \   source Session.vim |
  "     \ endif

  if has('nvim')
    autocmd TermOpen * setlocal nonumber norelativenumber
  elseif exists('##TerminalOpen')
    autocmd TerminalOpen * setlocal nonumber norelativenumber
  endif
  "set relative number
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * set nornu

  autocmd BufNewFile,BufRead *.icc                           set filetype=cpp
  autocmd BufNewFile,BufRead *.pde                           set filetype=java
  autocmd BufNewFile,BufRead *.coffee-processing             set filetype=coffee
  autocmd BufNewFile,BufRead Dockerfile*                     set filetype=dockerfile
  autocmd BufNewFile,BufRead *.wxml                          set filetype=xml
  autocmd BufNewFile,BufRead *.wxss                          set filetype=css

  " autocmd BufNewFile,BufRead *.md,*.mkd,*.markdown           set filetype=markdown.mkd
  autocmd FileType ruby setlocal regexpengine=1
  autocmd FileType ruby setlocal iskeyword+=!,?
  autocmd FileType ruby compiler ruby
  autocmd FileType eruby compiler eruby

  autocmd FileType coffee,javascript setlocal iskeyword+=$
  autocmd FileType c,cpp,cs,java,arduino setlocal commentstring=//\ %s
  autocmd FileType desktop              setlocal commentstring=#\ %s
  autocmd FileType sql                  setlocal commentstring=--\ %s
  autocmd FileType xdefaults            setlocal commentstring=!%s
  autocmd FileType git,gitcommit        setlocal foldmethod=syntax foldlevel=1
  autocmd FileType json                 setlocal foldmethod=syntax
  " set '-' to be part of a word when dealing with CSS classes and IDs.
  autocmd BufReadPost,BufNewFile *.{html,svg,xml,css,scss,less,stylus,js,coffee,erb,jade,blade} setlocal iskeyword+=-
  autocmd BufReadPost,BufNewFile *.json setlocal iskeyword+=-

  autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab ai |
        \compiler python
  autocmd Filetype gitcommit setlocal spell textwidth=72 colorcolumn=72

  autocmd BufRead,BufNewFile
    \ *zpath,.zlocal,zshenv.local,zlogin.local,zlogout.local,zshrc.local,zprofile.local,*/zsh/configs/*,
    \ set filetype=zsh
  autocmd BufRead,BufNewFile .env.*
    \ set filetype=sh
  autocmd BufRead,BufNewFile gitconfig,gitconfig.local set filetype=gitconfig
  autocmd BufRead,BufNewFile tmux.conf,tmux.conf.local set filetype=tmux
  autocmd BufRead,BufNewFile vimrc,vimrc.local set filetype=vim
  autocmd SessionLoadPost * call ChangeCWDTo(personal#project#find_home())
augroup END
" }}}
"
" ============================================================================
" COMMAND {{{
" ============================================================================
command! W :execute ':silent w !sudo tee % > /dev/null' | :edit!

command! Cnext try | cnext | catch | cfirst | catch | endtry
command! Cprev try | cprev | catch | clast | catch | endtry

command! Lnext try | lnext | catch | lfirst | catch | endtry
command! Lprev try | lprev | catch | llast | catch | endtry

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" REMOVE DUPLICATE LINES  {{{
" https://vim.fandom.com/wiki/Uniq_-_Removing_duplicate_lines
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! Uniq g/^\(.*\)\n\1$/d
" }}}
" }}}

" ============================================================================
" KEY MAP {{{
" ============================================================================
" Determining the highlight group that the word under the cursor belongs to
nmap <silent> <F11>   :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" " Prevent common mistake of pressing q: instead :q
" map q: :q

" visually select the text that was last edited/pasted (Vimcast#26).
noremap gV `[v`]

" expand %% to path of current buffer in command mode.
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

function! Tnoremap(lhs, rhs) abort
  if has('nvim')
    let s:cmd = 'tnoremap <silent>'.(a:lhs). ' '
    execute s:cmd . '<c-\><c-n>' . a:rhs
  elseif has('terminal') && exists(':terminal') == 2 && has('patch-8.1.1')
    let s:cmd = 'tnoremap <silent>'.(a:lhs). ' '
    let termwinkey = empty(&termwinkey) ? '<c-w>' : &termwinkey
    execute s:cmd . termwinkey . a:rhs
  endif
endfunction

" open a terminal window
if has('nvim')
  tnoremap <C-W><Esc>     <C-\><C-N>
  tnoremap <C-W>w         <C-\><C-N><bar><C-W>w
  tnoremap <C-W><C-W>     <C-\><C-N><bar><C-W>w
  tnoremap <expr> <C-W>" '<C-\><C-N>"'.nr2char(getchar()).'pi'
elseif has('terminal') && exists(':terminal') == 2 && has('patch-8.1.1')
  let termwinkey = empty(&termwinkey) ? '<c-w>' : &termwinkey
  execute 'tnoremap '. termwinkey .'<Esc> ' . termwinkey .'N'
endif

" https://vi.stackexchange.com/a/8535
nnoremap <silent> ]q :Cnext<cr>
nnoremap <silent> [q :Cprev<cr>
nnoremap <silent> ]l :Lnext<cr>
nnoremap <silent> [l :Lprev<cr>

" move line upforward/downward
nnoremap [e :<c-u>move .-2<CR>==
nnoremap ]e :<c-u>move .+1<CR>==
xnoremap <silent> <C-k> :move-2<cr>gv
xnoremap <silent> <C-j> :move'>+<cr>gv
" move line leftward/rightward
xnoremap > >gv
xnoremap < <gv
xnoremap <Tab> >gv
xnoremap <S-Tab> <gv
nnoremap >> >>_
nnoremap << <<_
xnoremap <silent> <C-l> >gv
xnoremap <silent> <C-h> <gv

noremap <C-a> <Home>
noremap <C-e> <End>

" https://stackoverflow.com/a/59950870
nnoremap <silent> zh :call HorizontalScrollMode('h')<CR>
nnoremap <silent> zl :call HorizontalScrollMode('l')<CR>
nnoremap <silent> zH :call HorizontalScrollMode('H')<CR>
nnoremap <silent> zL :call HorizontalScrollMode('L')<CR>

function! HorizontalScrollMode( call_char )
    if &wrap
        return
    endif

    echohl Title
    let typed_char = a:call_char
    while index( [ 'h', 'l', 'H', 'L' ], typed_char ) != -1
        execute 'normal! z'.typed_char
        redraws
        echon '-- Horizontal scrolling mode (h/l/H/L)'
        let typed_char = nr2char(getchar())
    endwhile
    echohl None | echo '' | redraws
endfunction

" close window
nnoremap <silent> q :quit<cr>
" use Q to record macro instead of q
noremap Q q

nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
" fast window switching: ALT+SHIFT+HJKL
noremap <m-H> <c-w>h
noremap <m-L> <c-w>l
noremap <m-J> <c-w>j
noremap <m-K> <c-w>k
if has('nvim')
  tnoremap <m-H> <c-\><c-N><bar><c-w>h
  tnoremap <m-L> <c-\><c-N><bar><c-w>l
  tnoremap <m-J> <c-\><c-N><bar><c-w>j
  tnoremap <m-K> <c-\><c-N><bar><c-w>k
  tnoremap <c-w>h <c-\><c-N><bar><c-w>h
  tnoremap <c-w>l <c-\><c-N><bar><c-w>l
  tnoremap <c-w>j <c-\><c-N><bar><c-w>j
  tnoremap <c-w>k <c-\><c-N><bar><c-w>k
  tnoremap <c-w><c-h> <c-\><c-N><bar><c-w>h
  tnoremap <c-w><c-l> <c-\><c-N><bar><c-w>l
  tnoremap <c-w><c-j> <c-\><c-N><bar><c-w>j
  tnoremap <c-w><c-k> <c-\><c-N><bar><c-w>k
elseif has('terminal') && exists(':terminal') == 2 && has('patch-8.1.1')
  let termwinkey = empty(&termwinkey) ? '<c-w>' : &termwinkey
  execute 'tnoremap <m-H> ' . termwinkey .'h'
  execute 'tnoremap <m-L> ' . termwinkey .'l'
  execute 'tnoremap <m-J> ' . termwinkey .'j'
  execute 'tnoremap <m-K> ' . termwinkey .'k'
endif
inoremap <m-H> <esc><c-w>h
inoremap <m-L> <esc><c-w>l
inoremap <m-J> <esc><c-w>j
inoremap <m-K> <esc><c-w>k

" save
inoremap <C-s>     <C-O>:update<cr>
nnoremap <C-s>     :update<cr>

" switch setting
map  <silent>          <leader>ee <Plug><ExpoloreToggle>
map  <silent><special> <F2>       <Plug><ExpoloreToggle>
imap <silent><special> <F2>       <Plug><ExpoloreToggle>

map  <Plug><ExpoloreToggle> :Lexplore<CR>
imap <Plug><ExpoloreToggle> <c-o>:<c-u>Lexplore<CR>

" remap U to <C-r> for easier redo
nnoremap U <C-r>
" y$ -> Y Make Y behave like other capitals
map Y y$

" Better x
nnoremap x "_x

" Better s
nnoremap s "_s

" Substitute.
xnoremap s :s//g<Left><Left>

" Swap implementations of ` and ' jump to markers
" By default, ' jumps to the marked line, ` jumps to the marked line and
" column, so swap them
nnoremap ' `
nnoremap ` '

" Improve scroll, credits: https://github.com/Shougo
nnoremap <expr> zz (winline() == (winheight(0)+1) / 2) ?
      \ 'zt' : (winline() == &scrolloff + 1) ? 'zb' : 'zz'

" Show last search in quickfix (http://travisjeffery.com/b/2011/10/m-x-occur-for-vim/)
nmap g/ :vimgrep /<C-R>//j %<CR>\|:cw<CR>

"Keep search pattern at the center of the screen."
nnoremap <silent> n nzz
nnoremap <silent> N Nzz

" Utility maps for repeatable quickly change/delete current word
nnoremap c*   *``cgn
nnoremap c#   *``cgN
nnoremap cg* g*``cgn
nnoremap cg# g*``cgN
nnoremap d*   *``dgn
nnoremap d#   *``dgN
nnoremap dg* g*``dgn
nnoremap dg# g*``dgN

" remove highlight
nnoremap <silent><leader>/ :nohls<CR>

function! ChangeCWDTo(dir) abort
  if exists(':tcd')
    execute 'tcd ' . expand(a:dir)
    echo 'cwd: ' . getcwd()
  else
    execute 'cd ' . expand(a:dir)
    echo 'cwd: ' . getcwd()
  end

  let g:test#project_root = a:dir
endfunction

" change cwd
noremap <silent> <leader>cd. :call ChangeCWDTo('%:p:h')<cr>
noremap <silent> <leader>cdp :call ChangeCWDTo(personal#project#find_home())<cr>

function! QFOpen()
  if exists(':Copen')
    bot Copen
  end
  bot copen
endfunction

" repeat last replacement operation
nnoremap g. /\V\C<C-r>"<CR>cgn<C-@>

nnoremap <silent> <leader>eq :call QFOpen()<CR>

nnoremap <silent> <F10> :call personal#functions#rotate_colors()<cr>
inoremap <C-k> <C-o>D

for s:i in range(1, 9)
  " <Leader>[1-9] move to tab [1-9]
  execute 'nnoremap <Leader>'.s:i s:i.'gt'
  execute 'nnoremap <m-'.s:i.'>' s:i.'gt'
  call Tnoremap('<m-'.s:i.'>', s:i.'gt')

  " <Leader>w[1-9] move to window [1-9]
  execute 'nnoremap <Leader>w'.s:i ' :'.s:i.'wincmd w<CR>'

  " <Leader>b[1-9] move to buffer [1-9]
  execute 'nnoremap <Leader>b'.s:i ':b'.s:i.'<CR>'
endfor
unlet s:i

" insert mode fast
inoremap <c-x>( ()<esc>i
inoremap <c-x>[ []<esc>i
inoremap <c-x>' ''<esc>i
inoremap <c-x>" ""<esc>i
inoremap <c-x>< <><esc>i
inoremap <c-x>{ {<esc>o}<esc>ko

inoremap <M-(> ()<esc>i
inoremap <M-[> []<esc>i
inoremap <M-'> ''<esc>i
inoremap <M-"> ""<esc>i
inoremap <M-<> <><esc>i
inoremap <M-{> {<esc>o}<esc>ko

map  <silent>          <leader>et <Plug><OutlineToggle>
map  <silent><special> <F8>       <Plug><OutlineToggle>
imap <silent><special> <F8>       <c-o>:<Plug><OutlineToggle>

" https://github.com/tpope/vim-unimpaired/blob/6d44a6dc2ec34607c41ec78acf81657248580bf1/plugin/unimpaired.vim#L460-L463
function! UrlEncode(str) abort
  " iconv trick to convert utf-8 bytes to 8bits indiviual char.
  return substitute(iconv(a:str, 'latin1', 'utf-8'),'[^A-Za-z0-9_.~-]','\="%".printf("%02X",char2nr(submatch(0)))','g')
endfunction

" https://forum.obsidian.md/t/open-note-in-obsidian-from-within-vim-and-vice-versa/6837
" Open file in Obsidian vault
nnoremap <silent> <leader>io :execute "silent !open 'obsidian://open?path=" . escape(UrlEncode(expand('%:p')), '%') . "'"<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RENAME CURRENT FILE {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RenameFile()
  let old_name = expand('%:~')
  let new_name = input('New file name: ', expand('%:~'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
map <leader>fr :call RenameFile()<cr>
"}}}

" if !exists("g:plugs") || !has_key(g:plugs, 'vim-rsi')
"   inoremap        <C-A> <Home>
"   inoremap   <C-X><C-A> <C-A>
"   cnoremap        <C-A> <Home>
"   cnoremap   <C-X><C-A> <C-A>

"   inoremap <expr> <C-B> getline('.')=~'^\s*$'&&col('.')>strlen(getline('.'))?"0\<Lt>C-D>\<Lt>Esc>kJs":"\<Lt>Left>"
"   cnoremap        <C-B> <Left>

"   inoremap <expr> <C-D> col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"
"   cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"

"   inoremap <expr> <C-E> col('.')>strlen(getline('.'))<bar><bar>pumvisible()?"\<Lt>C-E>":"\<Lt>End>"

"   inoremap <expr> <C-F> col('.')>strlen(getline('.'))?"\<Lt>C-F>":"\<Lt>Right>"
"   cnoremap <expr> <C-F> getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"
" end
" }}}
