" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50
set undolevels=1000
set ruler        " show the cursor position all the time
set showcmd      " display incomplete commands
set laststatus=2 " Always show status for last window
set incsearch
set number       " line numbers
set nobackup
set autoread
set ignorecase
set smartcase

set hlsearch   " Toggle with sh
set wrap       " Toggle with sw
" See map_toggle.vim for more toggle mappings

set shortmess=imrx

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

" Split settings
set splitbelow
set splitright

" Setup the menu stuff
set wildmenu
set wildmode=list:longest,full

" Looks
set listchars=tab:→\ ,eol:¬,nbsp:•

if has('nvim')
  set inccommand=nosplit
else
  set encoding=utf-8
endif
