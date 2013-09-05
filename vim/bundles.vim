" Don't load any bundles on old vim installations
" It's probably a server anyway...
if version < 702
  finish
endif

filetype off " required!

" Some hosts I work with does not support git-http
let g:vundle_default_git_proto = 'git'

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Vundle is an adult; it can manage itself
Bundle 'gmarik/vundle'

""" Dependency for vim-notes
Bundle 'xolox/vim-misc'

"" Dependency for vim-textobj-rubyblock
Bundle 'kana/vim-textobj-user'

""" Utility
Bundle 'DataWraith/auto_mkdir'
Bundle 'kana/vim-scratch'
Bundle 'kien/ctrlp.vim'
Bundle 'mileszs/ack.vim'
Bundle 'netrw.vim'
Bundle 'tpope/vim-eunuch'
Bundle 'tpope/vim-fugitive'
Bundle 'xolox/vim-notes'
Bundle 'SearchHighlighting'

""" Editor functionality
Bundle 'Shougo/neocomplcache'
Bundle 'UltiSnips'
Bundle 'bronson/vim-trailing-whitespace'
Bundle 'godlygeek/tabular'
Bundle 'gregsexton/gitv'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'nelstrom/vim-textobj-rubyblock'
Bundle 'scrooloose/syntastic'
Bundle 'tpope/vim-abolish'
Bundle 'tpope/vim-commentary'
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
Bundle 'timcharper/textile.vim'
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
Bundle 'chriskempson/vim-tomorrow-theme'

filetype plugin indent on " required!
