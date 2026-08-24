从 [wklken/k-vim](https://github.com/wklken/k-vim) 开始，随着自己使用的增加
而添加了一些自己用着舒服的配置。

当前配置运行时只支持 Neovim。插件仍采用 Vimscript + Lua 混合模式，保留成熟的
Vimscript 插件；服务器环境也通过 Neovim 使用同一套基础快捷键。

IDE 版是将 Neovim 作为正式开发环境的配置，包含经过筛选的 Vimscript 和 Lua 插件，
并尽量减少难以维护的外部依赖。

<!-- TOC GFM -->

* [依赖与安装](#依赖与安装)
    - [安装](#安装)
        + [依赖](#依赖)
* [功能](#功能)
    - [基础功能](#基础功能)
    - [IDE 版](#ide-版)
        + [搜索](#搜索)
        + [跳转](#跳转)
        + [文件浏览器](#文件浏览器)
        + [项目结构](#项目结构)
        + [补全](#补全)
        + [rails](#rails)
        + [美化](#美化)
        + [文档](#文档)
        + [其他](#其他)
* [Inspire](#inspire)

<!-- /TOC -->
## 依赖与安装

### 安装

```console
git clone https://github.com/jiz4oh/vim.git vim
./vim/install
```

#### 依赖

1. [neovim](https://github.com/neovim/neovim)
   至少需要 Neovim 0.9.4
2. [ripgrep](https://github.com/BurntSushi/ripgrep)
  可选, [安装教程](https://github.com/BurntSushi/ripgrep#installation)
3. [fzf](https://github.com/junegunn/fzf)
   可选，仅用于 shell 集成；Neovim 内的搜索由 fzf-lua 提供

## 功能:

### 基础功能

- 增量且大小写不敏感的搜索
- 新增窗口时总是在右边/下边
- 更轻松的缩进
- 使用 2 个空格代替制表符
- utf-8 优先
- 状态栏左侧显示当前文件，右侧显示当前行/列数
- 给插入模式添加常用的 emacs 快捷键
- 增加新的 text obj, <kbd>ie</kbd> / <kbd>iv</kbd>

快捷键|应用模式|描述
---|---|---
<kbd>F2</kbd>|n/i|打开文件管理器 netrw
<kbd>\<space>q</kbd>|n/i|打开 quickfix list
<kbd>q</kbd>|n|退出当前窗口，在最后一个窗口时不生效
<kbd>\<space>/</kbd>|n|移除搜索高亮
<kbd>U</kbd>|n|重做
<kbd>Y</kbd>|n|从光标处复制到行尾
<kbd>ctrl-h</kbd> / <kbd>ctrl-j</kbd> / <kbd>ctrl-k</kbd> / <kbd>ctrl-l</kbd>|n|移动光标到当前窗口的左/下/上/右侧窗口
<kbd>ctrl-a</kbd> / <kbd>ctrl-e</kbd>|n/v/i/c|移动光标到当前行首/尾
<kbd>ctrl-f</kbd> / <kbd>ctrl-b</kbd>|i|光标向右/左移一位
<kbd>ctrl-u</kbd> / <kbd>ctrl-k</kbd>|i|从光标处删除直到行首/尾
<kbd>>></kbd> / <kbd><<</kbd>|n|缩进/反向缩进
<kbd>></kbd> / <kbd><</kbd>|v|缩进/反向缩进
<kbd>alt-l</kbd> / <kbd>alt-h</kbd>|n/v/i|缩进/反向缩进
<kbd>[e</kbd> / <kbd>]e</kbd>|n/v|向上/下移动当前行
<kbd>alt-k</kbd> / <kbd>alt-j</kbd>|n/v/i|向上/下移动当前行
<kbd>\<space>cd</kbd>|n|将当前 buffer 所在目录作为工作目录
<kbd>\<space><tab></kbd>|n|切换到上一个 buffer
<kbd>\<space>tt</kbd> / <kbd><space>tv</kbd>|n|在下/右方打开终端
<kbd>\<C-W><Esc></kbd>|t|在终端中进入 normal 模式
<kbd>\<operate>ie</kbd>|n|<操作>当前 buffer
<kbd>\<operate>iv</kbd>|n|<操作>当前 buffer 可视范围

### IDE 版

- 包含基础快捷键，并使用 Oil、fzf-lua、Snacks、Outline 和 Gitsigns 扩展开发工作流

#### 搜索

插件：

- https://github.com/folke/snacks.nvim
- https://github.com/ibhagwan/fzf-lua
- https://github.com/BurntSushi/ripgrep

快捷键|速记|应用模式|描述
---|---|---|---
<kbd>\\</kbd>||v|在当前 buffer 向下搜索选中文本
<kbd>??</kbd>||v|在当前 buffer 向上搜索选中文本
<kbd>\<leader>s\<space></kbd>|ripgrep|n/v|使用 ripgrep 搜索文本
<kbd>\<leader>sp</kbd>|search project|n/v|在当前项目搜索文本
<kbd>\<leader>s]</kbd>|search tags|n|搜索 tags
<kbd>\<leader>si</kbd>|search paths|n/v|在配置的路径中搜索
<kbd>\<leader>sb</kbd>|search buffer|n|搜索当前 buffer 的行
<kbd>\<leader>sf</kbd>|search recent|n|搜索最近打开的文件
<kbd>\<leader>s'</kbd>|search marks|n|搜索 marks
<kbd>\<leader>s:</kbd>|search command history|n|搜索命令历史
<kbd>\<leader>s/</kbd>|search history|n|搜索搜索历史
<kbd>\<leader>ss</kbd>|search bookmarks|n|打开书签

命令|速记|描述
---|---|---
`Pg`|Project Grep|在当前项目搜索文件内容
`RG` / `Grep`|RipGrep|在当前工作目录下搜索文件内容
`GGrep` / `GitGrep`||在 git 仓库搜索文件名/内容
`Paths` / `Path`||在配置的路径中搜索
`Tags`||搜索 tags
`Packages`||搜索 Ruby、Go、Vim 或 JavaScript 包
`Bookmarks`||打开书签
`BookmarkAdd`||添加当前文件或指定路径书签
`BookmarkDelete`||删除用户书签

#### 跳转

插件：

- https://github.com/echasnovski/mini.jump
- https://github.com/echasnovski/mini.jump2d
- https://github.com/hedyhli/outline.nvim

快捷键|速记|应用模式|描述
---|---|---|---
<kbd>gl</kbd>|go to line|n|跳转到某行
<kbd>F2</kbd>||n|打开当前文件结构（Outline）

#### 文件浏览器

插件：

- https://github.com/stevearc/oil.nvim
- https://github.com/SirZenith/oil-vcs-status

快捷键|速记|应用模式|描述
---|---|---|---
<kbd>F1</kbd>||n/i|打开文件浏览器并定位到当前文件
<kbd>ctrl-e</kbd>|explore|n/i|打开文件浏览器
Oil 的目录缓冲区保留 Vim 风格的移动和文件操作；<kbd>F1</kbd> 用于打开并定位当前文件，
<kbd>ctrl-e</kbd> 用于打开当前目录。

#### 项目结构

插件：

- https://github.com/lewis6991/gitsigns.nvim
- https://github.com/tpope/vim-fugitive
- https://github.com/rbong/vim-flog
- https://github.com/linrongbin16/gitlinker.nvim

快捷键|速记|应用模式|描述
---|---|---|---
<kbd>\<space>hs</kbd>|hunk stage|n|暂存 当前修改块(hunk) 的改动
<kbd>\<space>hp</kbd>|hunk preview|n|预览 当前修改块(hunk) 的改动
<kbd>\<space>hu</kbd>|hunk undo|n|还原 当前修改块(hunk) 的改动
<kbd>\<space>g</kbd>|git|n|查看当前仓库状态，并可在上面进行 fugitive 操作
<kbd>\<space>b</kbd>|git blame messager|n|查看行的历史提交记录

#### 补全

插件：

- https://github.com/neovim/neovim
- https://github.com/neovim/nvim-lspconfig
- https://github.com/hrsh7th/nvim-cmp
- https://github.com/hrsh7th/cmp-nvim-lsp
- https://github.com/hrsh7th/cmp-buffer
- https://github.com/hrsh7th/cmp-path
- https://github.com/hrsh7th/cmp-cmdline
- https://github.com/Saghen/blink.cmp
- https://github.com/folke/snacks.nvim

快捷键|速记|应用模式|描述
---|---|---|---
<kbd>ctrl-n</kbd>||i/c|切换到下一个补全选项
<kbd>ctrl-p</kbd>||i/c|切换到上一个补全选项
<kbd>ctrl-e</kbd>|||取消选中的补全选项
<kbd>\<enter></kbd>||i/s/c|使用当前选中选项进行补全
<kbd>K</kbd>||n|查看当前符号对应的文档
<kbd>ctrl-f</kbd>||n|向下移动文档
<kbd>ctrl-b</kbd>||n|向上移动文档
<kbd>gd</kbd>|go to definition|n|跳转到定义；多个结果由 fzf-lua 选择
<kbd>gD</kbd>|go to declaration|n|跳转到声明；多个结果由 fzf-lua 选择
<kbd>gr</kbd>|go to references|n|跳转到引用；多个结果由 fzf-lua 选择
<kbd>gi</kbd>|go to implementation|n|跳转到实现；多个结果由 fzf-lua 选择
<kbd>[d</kbd>|diagnostic|n|跳转到上一个语法错误
<kbd>]d</kbd>|diagnostic|n|跳转到下一个语法错误
<kbd>\<space>f</kbd>|format|n|根据语法检查格式化当前 buffer

#### rails

插件：

- https://github.com/tpope/vim-bundler
- https://github.com/tpope/vim-rails
- https://github.com/tpope/vim-dispatch

快捷键|速记|应用模式|描述
---|---|---|---
<kbd>gf</kbd>|go to file|n|跳转到 has_many,belongs_to 等关系对应的类

#### 美化

插件:

- https://github.com/ryanoasis/vim-devicons
- https://github.com/luochen1990/rainbow
- https://github.com/sonph/onehalf

#### 文档

插件:

- https://github.com/brianhuster/live-preview.nvim
- https://github.com/iamcco/markdown-preview.nvim
- https://github.com/lervag/wiki.vim
- https://github.com/mzlogin/vim-markdown-toc
- https://github.com/kkoomen/vim-doge
- https://github.com/junegunn/goyo.vim

快捷键|速记|应用模式|描述
---|---|---|---
<kbd>\<space>ww</kbd>||n|打开 wiki 索引页
<kbd>\<space>w<space>w</kbd>||n|打开今日日记
-<kbd>\<space>d</kbd>|document|n|为当前光标下的函数生成文档格式，并通过 <kbd>Tab</kbd> 切换到下一个文档

命令|速记|描述
---|---|---
`MarkdownPreview`||默认映射到 `LivePreview start`
`Goyo`||切换勿扰模式

#### 其他

插件：

- https://github.com/sheerun/vim-polyglot
- https://github.com/tpope/vim-rsi
- https://github.com/tpope/vim-endwise
- https://github.com/tpope/vim-commentary
- https://github.com/svermeulen/vim-cutlass
   vim 原始的 c,s,d 会将删除内容保存在寄存器中，更类似于剪切功能。
   vim-cutlass 使 c,s,d 不再破坏寄存器，
   而我选择将 c 映射为原始的 d
- https://github.com/ludovicchabant/vim-gutentags
- https://github.com/justinmk/vim-gtfo
- https://github.com/AndrewRadev/splitjoin.vim

快捷键|速记|应用模式|描述
---|---|---|---
<kbd>gJ</kbd>|go to join|n|将多行代码缩写为一行
<kbd>gK</kbd>||n|将一行代码展开为多行
<kbd>gof</kbd>|go to file explore|n|使用文件管理器打开当前 buffer 所在目录
<kbd>got</kbd>|go to file explore|n|使用终端打开当前 buffer 所在目录
<kbd>cc</kbd>|cut|n|等于 dd
<kbd>c</kbd>|cut|n|等于 d
<kbd>gcc</kbd>|comment/uncomment|n|注释/取消注释
<kbd>gc</kbd>|comment|v|注释/取消注释
<kbd>\<space><space>i</kbd>|install|n|安装插件

## Inspire

- [Vim-plug](https://github.com/junegunn/vim-plug)
- [vim-for-server](https://github.com/wklken/vim-for-server)
- [Vime](https://github.com/fgheng/vime)
