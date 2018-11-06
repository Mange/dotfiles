" Don't load any bundles on old vim installations
" It's probably a server anyway...
if version < 702
  finish
endif

call plug#begin($XDG_DATA_HOME . '/nvim/plugged')

""" Looks
Plug 'ap/vim-css-color', {'for': ['css', 'html', 'scss', 'conf']}
Plug 'bling/vim-airline'
Plug 'morhetz/gruvbox'

""" Utility
Plug 'DataWraith/auto_mkdir'
Plug 'vim-scripts/ingo-library' | Plug 'vim-scripts/SearchHighlighting'

Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-startify'
Plug 'rking/ag.vim', {'on': ['Ag', 'AgFromSearch']}
Plug 'tpope/vim-eunuch' " Adds things like :Move, :Rename, :SudoWrite, etc.
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-vinegar' " Improves netrw, adds '-' binding to open current dir in netrw, etc.

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

""" Editor functionality
Plug 'AndrewRadev/switch.vim'
Plug 'Shougo/context_filetype.vim' " Tries to add support for languages-inside-languages (fenced code blocks, etc.)
Plug 'bronson/vim-trailing-whitespace'
Plug 'junegunn/vim-easy-align'
Plug 'kien/rainbow_parentheses.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'maralla/completor.vim'
Plug 'michaeljsmith/vim-indent-object'
Plug 'neomake/neomake'
Plug 'terryma/vim-multiple-cursors'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-abolish' " Smart S/re/repl/
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating' " CTRL-X/A works on dates
Plug 'tpope/vim-surround'
Plug 'vim-scripts/ZoomWin'

""" Ruby
Plug 'joker1007/vim-ruby-heredoc-syntax', {'for': 'ruby'}
Plug 'kana/vim-textobj-user' | Plug 'nelstrom/vim-textobj-rubyblock'
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
Plug 'dahu/vimple', {'for': 'asciidoc'}
Plug 'dahu/Asif', {'for': 'asciidoc'}
Plug 'Raimondi/VimRegStyle', {'for': 'asciidoc'}
Plug 'vim-scripts/SyntaxRange', {'for': 'asciidoc'}
Plug 'dahu/vim-asciidoc', {'for': 'asciidoc'}

""" JS
Plug 'ElmCast/elm-vim', {'for': 'elm'}
Plug 'jelera/vim-javascript-syntax', {'for': 'javascript'}
Plug 'leafgarland/typescript-vim', {'for': ['javascript', 'typescript', 'vue']}
Plug 'posva/vim-vue', {'for': ['javascript', 'typescript', 'vue']}
Plug 'vim-scripts/JSON.vim'

""" HTML/CSS
Plug 'gregsexton/MatchTag', {'for': 'html'}
Plug 'othree/html5-syntax.vim', {'for': 'html'}

""" Misc
Plug 'jparise/vim-graphql', {'for': 'graphql'}
Plug 'hashivim/vim-terraform', {'for': 'terraform'}

call plug#end()
