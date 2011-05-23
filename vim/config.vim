set nocompatible

let g:CommandTMaxHeight=20

source ~/.vim/bundles.vim
helptags ~/.vim/vundle/doc

syntax on
filetype plugin indent on

" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

function! GitStatusLine()
  if exists('g:loaded_fugitive')
    return fugitive#statusline()
  endif
  return "(fugitive not loaded)"
endfunction

set statusline=%{GitStatusLine()}\ %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

