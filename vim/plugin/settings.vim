" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50
set undolevels=1000
set ruler      " show the cursor position all the time
set showcmd    " display incomplete commands
set incsearch
set number     " line numbers
set nobackup
set autoread
set ignorecase
set smartcase

" Use linear search in tags when smartcase and ignorecase is set,
" otherwise SuperTab gives a load of errors all the time
set notagbsearch

set hlsearch   " Toggle with sh
set wrap       " Toggle with sw
" See map_toggle.vim for more toggle mappings

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

" Setup the menu stuff
set wildmenu
set wildmode=list:longest,full

" Have swapfiles in a separate directory
set dir=~/.vim/tmp

" Looks
set background=dark
colorscheme Tomorrow-Night
set listchars=tab:→\ ,eol:¬
