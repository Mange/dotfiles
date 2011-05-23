filetype off " required!

set rtp+=~/.vim/vundle/
call vundle#rc()

" GitHub
Bundle 'ap/vim-css-color'
Bundle 'bronson/vim-trailing-whitespace'
Bundle 'ecomba/vim-ruby-refactoring'
Bundle 'ervandew/supertab'
Bundle 'godlygeek/tabular'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'mileszs/ack.vim'
Bundle 'othree/html5-syntax.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'tpope/vim-cucumber'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-surround'
Bundle 'vim-ruby/vim-ruby'

" vim-scripts
Bundle 'JSON.vim'
Bundle 'rename'
Bundle 'zoomwin'
Bundle 'netrw.vim'

" other Git
Bundle 'git://git.wincent.com/command-t.git'

" Should I still keep these?
Bundle 'mexpolk/vim-taglist'
Bundle 'scrooloose/nerdtree'

" Will be removed/changed soon
Bundle 'msanders/snipmate.vim'

filetype plugin indent on " required!

