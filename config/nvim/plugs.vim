" Don't load any bundles on old vim installations
" It's probably a server anyway...
if version < 702
  finish
endif

call plug#begin($XDG_DATA_HOME . '/nvim/plugged')

""" Looks
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

Plug 'liuchengxu/vim-which-key'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

""" Note taking / TODOs
" vimwiki
Plug 'vimwiki/vimwiki'

" taskwarrior
Plug 'blindFS/vim-taskwarrior'

" taskwarrior in vimwiki
Plug 'tbabej/taskwiki', { 'do': 'sudo pip3 install --upgrade -r requirements.txt' }

""" Editor functionality
Plug 'AndrewRadev/switch.vim'
Plug 'Shougo/context_filetype.vim' " Tries to add support for languages-inside-languages (fenced code blocks, etc.)
Plug 'bronson/vim-trailing-whitespace'
Plug 'junegunn/vim-easy-align'
Plug 'kien/rainbow_parentheses.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'meain/vim-package-info', { 'do': 'npm install' }
Plug 'michaeljsmith/vim-indent-object'
Plug 'terryma/vim-multiple-cursors'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-abolish' " Smart S/re/repl/
Plug 'tpope/vim-commentary'
" Plug 'tpope/vim-endwise' " Conflicts with coc: https://github.com/tpope/vim-endwise/issues/22
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating' " CTRL-X/A works on dates
Plug 'tpope/vim-surround'
Plug 'vim-scripts/ZoomWin'

""" Language server support, linting, etc.
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}
Plug 'w0rp/ale'
Plug 'sheerun/vim-polyglot'
Plug 'calviken/vim-gdscript3'

""" Ruby
Plug 'joker1007/vim-ruby-heredoc-syntax', {'for': 'ruby'}
Plug 'kana/vim-textobj-user' | Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'tpope/vim-bundler', {'for': 'ruby'}
Plug 'tpope/vim-rails', {'for': 'ruby'}
Plug 'tpope/vim-rake', {'for': 'ruby'}
Plug 'tpope/vim-rvm', {'for': 'ruby'}
Plug 'vim-scripts/ruby-matchit', {'for': 'ruby'}

""" HTML/CSS
Plug 'gregsexton/MatchTag', {'for': 'html'}

call plug#end()
