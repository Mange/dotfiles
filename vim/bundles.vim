" Don't load any bundles on old vim installations
" It's probably a server anyway...
if version < 702
  finish
endif

filetype off " required!

if has('vim_starting')
  set nocompatible
  set rtp+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand("~/.vim/bundle/"))

" NeoBundle is an adult; it can manage itself
NeoBundle 'Shougo/neobundle.vim'

""" Dependency for vim-notes
NeoBundle 'xolox/vim-misc'

"" Dependency for vim-textobj-rubyblock
NeoBundle 'kana/vim-textobj-user'

""" Improves NeoBundle, Unite, etc.
NeoBundle 'Shougo/vimproc', {
      \ 'build' : {
      \     'windows' : 'make -f make_mingw32.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }

""" Utility
NeoBundle 'DataWraith/auto_mkdir'
NeoBundle 'kana/vim-scratch'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'mileszs/ack.vim'
NeoBundle 'netrw.vim'
NeoBundle 'tpope/vim-eunuch'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'xolox/vim-notes'
NeoBundle 'SearchHighlighting'

""" Editor functionality
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'UltiSnips'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'godlygeek/tabular'
NeoBundle 'gregsexton/gitv'
NeoBundle 'michaeljsmith/vim-indent-object'
NeoBundle 'nelstrom/vim-textobj-rubyblock'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'tpope/vim-abolish'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-surround'

" Mirror; VBA from original source does not install
NeoBundle 'vim-scripts/ZoomWin'

""" Ruby
NeoBundle 'tpope/vim-bundler'
NeoBundle 'tpope/vim-rvm'

NeoBundle 'ecomba/vim-ruby-refactoring'
NeoBundle 'ruby-matchit'
NeoBundle 'tpope/vim-rails'
NeoBundle 'tpope/vim-rake'
NeoBundle 'vim-ruby/vim-ruby'

NeoBundle 'tpope/vim-haml'

NeoBundle 'nanki/treetop.vim'

""" JS
NeoBundle 'JSON.vim'

NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'pangloss/vim-javascript'

""" HTML
NeoBundle 'othree/html5-syntax.vim'

""" Misc
NeoBundle 'puppetlabs/puppet-syntax-vim'
NeoBundle 'timcharper/textile.vim'
NeoBundle 'tpope/vim-cucumber'
NeoBundle 'tpope/vim-markdown'

""" Looks
NeoBundle 'Lokaltog/vim-powerline'
NeoBundle 'ap/vim-css-color'
NeoBundle 'chriskempson/vim-tomorrow-theme'

filetype plugin indent on " required!

NeoBundleCheck
