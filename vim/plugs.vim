" Don't load any bundles on old vim installations
" It's probably a server anyway...
if version < 702
  finish
endif

call plug#begin('~/.vim/plugged')

" fzf cannot run properly in GUI MacVim. Terminal MacVim, or other graphical
" Vims handles it fine.
if isdirectory("/usr/local/opt/fzf") && !(has("gui_macvim") && has("gui_running"))
  let g:use_fzf = 1
  Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
else
  let g:use_fzf = 0
  Plug 'kien/ctrlp.vim'
endif

""" Utility
Plug 'DataWraith/auto_mkdir'
Plug 'FelikZ/ctrlp-py-matcher'
Plug 'ingo-library' | Plug 'SearchHighlighting'

Plug 'airblade/vim-gitgutter'
Plug 'netrw.vim'
Plug 'rizzatti/dash.vim'
Plug 'rking/ag.vim', {'on': ['Ag', 'AgFromSearch']}
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-vinegar'
Plug 'xolox/vim-misc' | Plug 'xolox/vim-notes'

""" Editor functionality
Plug 'AndrewRadev/switch.vim'
Plug 'bronson/vim-trailing-whitespace'
Plug 'haya14busa/incsearch.vim'
Plug 'junegunn/vim-easy-align'
Plug 'kana/vim-textobj-user' | Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'kien/rainbow_parentheses.vim'
Plug 'michaeljsmith/vim-indent-object'
Plug 'neomake/neomake'
Plug 'terryma/vim-multiple-cursors'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/ZoomWin'

""" Ruby
Plug 'tpope/vim-bundler', {'for': 'ruby'}
Plug 'tpope/vim-rvm', {'for': 'ruby'}

Plug 'ecomba/vim-ruby-refactoring', {'for': 'ruby'}
Plug 'ruby-matchit', {'for': 'ruby'}
Plug 'tpope/vim-rails', {'for': 'ruby'}
Plug 'tpope/vim-rake', {'for': 'ruby'}
Plug 'vim-ruby/vim-ruby', {'for': 'ruby'}

""" Go
Plug 'fatih/vim-go'

""" Rust
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer', {'for': 'rust'}

""" JS
Plug 'JSON.vim'
Plug 'jelera/vim-javascript-syntax', {'for': 'javascript'}

""" HTML/CSS
Plug 'gregsexton/MatchTag', {'for': 'html'}
Plug 'othree/html5-syntax.vim', {'for': 'html'}

""" Misc
Plug 'jparise/vim-graphql'
Plug 'puppetlabs/puppet-syntax-vim'
Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
Plug 'hashivim/vim-terraform'

""" Looks
Plug 'ap/vim-css-color', {'for': ['css', 'html', 'scss', 'conf']}
Plug 'bling/vim-airline'
Plug 'morhetz/gruvbox'

call plug#end()
