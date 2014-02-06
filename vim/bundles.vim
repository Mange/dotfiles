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

"" Dependency for vim-textobj-rubyblock and other custom textobj plugins
NeoBundle 'kana/vim-textobj-user'

""" Utility
NeoBundle 'DataWraith/auto_mkdir'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'mileszs/ack.vim'
NeoBundle 'netrw.vim'
NeoBundle 'tpope/vim-eunuch'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'xolox/vim-notes', {'depends': ['xolox/vim-misc']}
NeoBundle 'SearchHighlighting', {'depends': ['ingo-library']}
NeoBundle 'mhinz/vim-signify'

""" Editor functionality
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'UltiSnips'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'godlygeek/tabular'
NeoBundle 'michaeljsmith/vim-indent-object'
NeoBundle 'nelstrom/vim-textobj-rubyblock'
NeoBundle 'tommcdo/vim-exchange'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'tpope/vim-abolish'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-surround'
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

""" HTML/CSS
NeoBundle 'othree/html5-syntax.vim'
NeoBundle 'groenewege/vim-less'

""" Misc
NeoBundle 'puppetlabs/puppet-syntax-vim'
NeoBundle 'timcharper/textile.vim'
NeoBundle 'tpope/vim-cucumber'
NeoBundle 'tpope/vim-markdown'

""" Looks
NeoBundle 'ap/vim-css-color'
NeoBundle 'bling/vim-airline'
NeoBundle 'chriskempson/vim-tomorrow-theme'

filetype plugin indent on " required!

NeoBundleCheck
