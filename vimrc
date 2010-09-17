" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

set guioptions=acei

" Pathogen
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50
set undolevels=1000
set ruler      " show the cursor position all the time
set showcmd    " display incomplete commands
set incsearch
set hlsearch
set number     " line numbers
set nobackup
set wrap

set shortmess=imrx
set cmdheight=2

set scrolloff=10
set sidescrolloff=10

" Autoindent and Smartindent on
set autoindent
set smartindent

" Tab settings
set expandtab
set tabstop=2
set shiftwidth=2
set smarttab

syntax on
filetype plugin indent on

" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

" Shift-H and Shift-L to switch tabs
map <S-h> gT
map <S-l> gt

" Setup the menu stuff
set wildmenu
set wildmode=list:longest,full

" Shortcuts to use system clipboard
if v:progname =~? "gvim"
  vmap <C-c> "+y
  vmap <C-x> "+x
  nmap <C-v> "+p
  nmap <S-C-v> "+P
endif

" Shortcut for saving in all modes
map <C-s> <C-o>:w<cr>

" Highlight invisible characters
set listchars=eol:¬,tab:→\ 
set list

" Set the colorscheme and the background
set background=dark
colorscheme vividchalk
