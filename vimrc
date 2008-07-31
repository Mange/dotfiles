" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set number		" line numbers

" Set the colorscheme and the background
set background=dark
colorscheme desert
" Autoindent and Smartindent on
set autoindent
set smartindent

" enable code folding if using vim above version 6
if version >= 600
   set foldenable
   set foldmethod=marker
endif

" Tab settings
set expandtab
set tabstop=5
set shiftwidth=5
set smarttab

syntax on
set hlsearch

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
	 	\ | wincmd p | diffthis

" Shift-H and Shift-L to switch tabs
map <S-h> gT
map <S-l> gt

" Sse "[RO]" for "[readonly]" to save space in the message line
set shortmess+=r

" Set the statusbar height to two lines
set cmdheight=2

" No beeps on error messages
set noerrorbells

" Don't create back-up files
set nobackup

" Enable backspacing over everything
set bs=2

" Set the encoding to UTF-8
set encoding=utf-8

" Search for text as you type
set incsearch

" Source filetype plugins.
runtime! ftdetect/*.vim

" Set the status line format.
set laststatus=2
if has("statusline")
     set statusline=%F%m%r%h%w\ [%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")} 
endif

" Enable line wrapping.
set wrap

" Set the shortmess options
set shortmess=atI

" Set the number of undo levels
set undolevels=1000

" Autocommands used for *.txt files
augroup Txt
     autocmd BufNewFile,BufRead *.txt   setf txt
augroup END

" Autowrite on swap
set autowrite
set noshowcmd

" Setup the menu stuff
set wildmenu
set cpo-=<
set wcm=<C-Z>
map <F4> :emenu <C-Z>
set wildmode=list:longest,full 

" Copy + Paste(enables the use of ctrl-v, c and x to paste, copy and cut
nnoremap <silent> <sid>Paste :call <sid>Paste()<cr>
vnoremap <c-x> "+x
vnoremap <c-c> "+y
map <c-v> "+gP
cmap <c-v> <c-r>+
func! <sid>Paste()
    let ove = &ve
    set ve=all
    normal `^
    if @+ != ''
        normal "+gP
    endif
    let c = col(".")
    normal i
    if col(".") < c
        normal l
    endif
    let &ve = ove
endfunc
inoremap <script> <c-v> x<bs><esc><sid>Pastegi
vnoremap <script> <c-v> "-c<esc><sid>Paste

" Set up backup directory
set backupdir=$HOME/.tmp/  

