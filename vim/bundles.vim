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

call neobundle#begin(expand("~/.vim/bundle/"))

" NeoBundle is an adult; it can manage itself
NeoBundleFetch 'Shougo/neobundle.vim'

"" Dependency for vim-textobj-rubyblock and other custom textobj plugins
NeoBundle 'kana/vim-textobj-user'

""" Utility
NeoBundle 'DataWraith/auto_mkdir'
NeoBundle 'FelikZ/ctrlp-py-matcher'
NeoBundle 'SearchHighlighting', {'depends': ['ingo-library']}
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'mhinz/vim-signify'
NeoBundle 'netrw.vim'
NeoBundle 'rizzatti/dash.vim'
NeoBundle 'rking/ag.vim'
NeoBundle 'tpope/vim-eunuch'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-vinegar'
NeoBundle 'xolox/vim-notes', {'depends': ['xolox/vim-misc']}

""" Editor functionality
NeoBundle 'AndrewRadev/switch.vim'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'godlygeek/tabular'
NeoBundle 'haya14busa/incsearch.vim'
NeoBundle 'michaeljsmith/vim-indent-object'
NeoBundle 'nelstrom/vim-textobj-rubyblock'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'tommcdo/vim-exchange'
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

""" Scala
NeoBundle 'derekwyatt/vim-scala'

""" Go
NeoBundle 'fatih/vim-go'

""" Rust
NeoBundle 'rust-lang/rust.vim'
NeoBundle 'racer-rust/vim-racer'

""" JS
NeoBundle 'JSON.vim'

NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'jelera/vim-javascript-syntax', {'autoload':{'filetypes':['javascript']}}

""" HTML/CSS
NeoBundle 'gregsexton/MatchTag'
NeoBundle 'othree/html5-syntax.vim'

""" Misc
NeoBundle 'puppetlabs/puppet-syntax-vim'
NeoBundle 'suan/vim-instant-markdown'

""" Looks
NeoBundle 'ap/vim-css-color'
NeoBundle 'bling/vim-airline'
NeoBundle 'chriskempson/vim-tomorrow-theme'

call neobundle#end()

" required!
filetype plugin indent on

NeoBundleCheck
