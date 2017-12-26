" Don't load any bundles on old vim installations
" It's probably a server anyway...
if version < 702
  finish
endif

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

""" Utility
Plug 'DataWraith/auto_mkdir'
Plug 'vim-scripts/ingo-library' | Plug 'vim-scripts/SearchHighlighting'

Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-startify'
Plug 'rizzatti/dash.vim'
Plug 'rking/ag.vim', {'on': ['Ag', 'AgFromSearch']}
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-vinegar'
Plug 'xolox/vim-misc' | Plug 'xolox/vim-notes'

""" Editor functionality
Plug 'AndrewRadev/switch.vim'
Plug 'Shougo/context_filetype.vim'
Plug 'bronson/vim-trailing-whitespace'
Plug 'junegunn/vim-easy-align'
Plug 'kana/vim-textobj-user' | Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'kien/rainbow_parentheses.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'maralla/completor.vim'
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
Plug 'ecomba/vim-ruby-refactoring', {'for': 'ruby'}
Plug 'joker1007/vim-ruby-heredoc-syntax', {'for': 'ruby'}
Plug 'tpope/vim-bundler', {'for': 'ruby'}
Plug 'tpope/vim-rails', {'for': 'ruby'}
Plug 'tpope/vim-rake', {'for': 'ruby'}
Plug 'tpope/vim-rvm', {'for': 'ruby'}
Plug 'vim-ruby/vim-ruby', {'for': 'ruby'}
Plug 'vim-scripts/ruby-matchit', {'for': 'ruby'}

""" Rust
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer', {'for': 'rust'}

""" ASCIIdoc
let vimple_init_vars = 0 " https://github.com/dahu/vimple/issues/11
Plug 'dahu/vimple'
Plug 'dahu/Asif'
Plug 'Raimondi/VimRegStyle'
Plug 'vim-scripts/SyntaxRange'
Plug 'dahu/vim-asciidoc'

""" JS
Plug 'vim-scripts/JSON.vim'
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
