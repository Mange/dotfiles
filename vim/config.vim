set nocompatible

runtime! before/**/*.vim

" Run local overrides if existing
runtime! local_*.vim

syntax on
filetype plugin indent on

source ~/.vim/bundles.vim
