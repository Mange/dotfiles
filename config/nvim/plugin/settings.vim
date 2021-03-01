" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set foldlevel=99
set history=100
set undolevels=1000
set ruler        " show the cursor position all the time
set showcmd      " display incomplete commands
set laststatus=2 " Always show status for last window
set number       " line numbers
set nobackup
set autoread

" Search settings
set incsearch
set ignorecase
set smartcase
set hlsearch
set wrap

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

" Tags
set tags^=./.git/tags; " Load tags written by my Git hooks
set tags+=./rusty-tags.vi; " Semicolon means search parents recursively until found
if !empty($RUST_SRC_PATH)
  set tags+=$RUST_SRC_PATH/rusty-tags.vi
endif

if has('nvim')
  set inccommand=nosplit
else
  set encoding=utf-8
endif
