set nocompatible

let g:CommandTMaxHeight = 20

" netrw
let g:netrw_liststyle="tree"

" let g:easytags_suppress_ctags_warning = 1
let g:easytags_resolve_links = 1
let g:easytags_cmd = '/usr/local/bin/ctags'
let g:easytags_dynamic_files = 1

let g:UltiSnipsEditSplit = "horizontal"
let g:UltiSnipsExpandTrigger = "<c-tab>"
let g:UltiSnipsListSnippets = "<c-s-tab>"

if isdirectory($HOME . '/Dropbox/Notes')
  let g:notes_directory = '~/Dropbox/Notes'
elseif isdirectory($HOME . '/Documents/Notes')
  let g:notes_directory = '~/Documents/Notes'
endif

source ~/.vim/bundles.vim

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

