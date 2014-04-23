set nocompatible

runtime! before/**/*.vim

source ~/.vim/bundles.vim

" Run local overrides if existing
runtime! local_*.vim

syntax on
filetype plugin indent on

" Some bundle seem to be disabling this. Reset to defaults.
set modeline
set modelines=5
