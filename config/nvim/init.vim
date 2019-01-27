set nocompatible

if has("termguicolor")
  set termguicolor
endif

" Support system-installed vim plugins
set runtimepath^=/usr/share/vim/vimfiles

runtime! before/**/*.vim

runtime plugs.vim

" Run local overrides if existing
runtime! local_*.vim

syntax on
filetype plugin indent on

" Some bundle seem to be disabling this. Reset to defaults.
set modeline
set modelines=5

" Allow project-specific .vimrc
set exrc
set secure " Don't allow certain things in project RCs that are not owned by me

" Set terminal/window title from current file.
set title
