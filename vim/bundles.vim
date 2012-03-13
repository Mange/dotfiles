filetype off " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Vundle is an adult; it can manage itself
Bundle 'gmarik/vundle'

""" Utility
Bundle 'kana/vim-scratch'
Bundle 'kien/ctrlp.vim'
Bundle 'mileszs/ack.vim'
Bundle 'netrw.vim'
Bundle 'tpope/vim-eunuch'
Bundle 'tpope/vim-fugitive'
Bundle 'xolox/vim-notes'

""" Editor functionality
Bundle 'Shougo/neocomplcache'
Bundle 'Townk/vim-autoclose'
Bundle 'UltiSnips'
Bundle 'bronson/vim-trailing-whitespace'
Bundle 'godlygeek/tabular'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'scrooloose/nerdcommenter'
Bundle 'scrooloose/syntastic'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-surround'

" Mirror; VBA from original source does not install
Bundle 'vim-scripts/ZoomWin'

""" Filetypes, projects, etc.
Bundle 'JSON.vim'
Bundle 'ecomba/vim-ruby-refactoring'
Bundle 'kchmck/vim-coffee-script'
Bundle 'nanki/treetop.vim'
Bundle 'othree/html5-syntax.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'puppetlabs/puppet-syntax-vim'
Bundle 'ruby-matchit'
Bundle 'tpope/vim-bundler'
Bundle 'tpope/vim-cucumber'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-rake'
Bundle 'tpope/vim-rvm'
Bundle 'vim-ruby/vim-ruby'

""" Looks
Bundle 'Lokaltog/vim-powerline'
Bundle 'ap/vim-css-color'
Bundle 'chriskempson/Vim-Tomorrow-Theme'

filetype plugin indent on " required!
