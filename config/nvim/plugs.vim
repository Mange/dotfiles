" Don't load any bundles on old vim installations
" It's probably a server anyway...
if version < 702
  finish
endif

call plug#begin($XDG_DATA_HOME . '/nvim/plugged')

Plug 'morhetz/gruvbox'
Plug 'DataWraith/auto_mkdir'
Plug 'rking/ag.vim', {'on': ['Ag', 'AgFromSearch']}
Plug 'tpope/vim-eunuch' " Adds things like :Move, :Rename, :SudoWrite, etc.
Plug 'tpope/vim-vinegar' " Improves netrw, adds '-' binding to open current dir in netrw, etc.
Plug 'liuchengxu/vim-which-key'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'AndrewRadev/switch.vim'
Plug 'Shougo/context_filetype.vim' " Tries to add support for languages-inside-languages (fenced code blocks, etc.)
Plug 'bronson/vim-trailing-whitespace'
Plug 'machakann/vim-highlightedyank'
Plug 'michaeljsmith/vim-indent-object'
Plug 'terryma/vim-multiple-cursors'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-abolish' " Smart S/re/repl/
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating' " CTRL-X/A works on dates
Plug 'tpope/vim-surround'
Plug 'vim-scripts/ZoomWin'

Plug 'sheerun/vim-polyglot'

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

" On some servers only older versions of neovim is installed; try to support a
" limited mode for those cases.
if has("nvim-0.4.0")
  let g:mange_full_nvim=1

  Plug 'bling/vim-airline'
  Plug 'vim-scripts/ingo-library' | Plug 'vim-scripts/SearchHighlighting'
  Plug 'Yggdroot/indentLine'
  Plug 'airblade/vim-gitgutter'
  Plug 'mhinz/vim-startify'
  Plug 'tpope/vim-fugitive'
  Plug 'liuchengxu/vista.vim'

  Plug 'vimwiki/vimwiki'
  Plug 'blindFS/vim-taskwarrior'
  Plug 'tbabej/taskwiki', { 'do': 'sudo pip3 install --user --upgrade -r requirements.txt' }

  Plug 'SirVer/ultisnips'
  Plug 'junegunn/vim-easy-align'
  Plug 'kien/rainbow_parentheses.vim'
  Plug 'meain/vim-package-info', { 'do': 'npm install' }

  """ Language server support, linting, etc.
  Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': { -> coc#util#install()}}
  Plug 'w0rp/ale'
  Plug 'calviken/vim-gdscript3'
else
  let g:mange_full_nvim=0
endif

call plug#end()
