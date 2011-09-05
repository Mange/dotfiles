filetype off " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Vundle should handle itself
Bundle 'gmarik/vundle'

" GitHub
Bundle 'ap/vim-css-color'
Bundle 'bronson/vim-trailing-whitespace'
Bundle 'ecomba/vim-ruby-refactoring'
Bundle 'ervandew/supertab'
Bundle 'godlygeek/tabular'
Bundle 'kana/vim-scratch'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'mileszs/ack.vim'
Bundle 'nanki/treetop.vim'
Bundle 'othree/html5-syntax.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'spiiph/vim-space'
Bundle 'tpope/vim-bundler'
Bundle 'tpope/vim-cucumber'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-surround'
Bundle 'vim-ruby/vim-ruby'
Bundle 'xolox/vim-easytags'
Bundle 'xolox/vim-notes'

" Mirror needed since VBA from original source does not seem to install
Bundle 'vim-scripts/ZoomWin'

" vim-scripts
Bundle 'JSON.vim'
Bundle 'Rename'
Bundle 'UltiSnips'
Bundle 'netrw.vim'
Bundle 'ruby-matchit'

" other Git
Bundle 'git://git.wincent.com/command-t.git'

" Should I still keep these?
Bundle 'mexpolk/vim-taglist'
Bundle 'scrooloose/nerdtree'

filetype plugin indent on " required!

