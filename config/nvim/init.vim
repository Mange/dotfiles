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

" Dot not allow insecure .vimrc files in projects, but emulate something
" better by always looking for a `<cwd>/.git/local.vim` file and sourcing it
" via `after/project_settings.vim`.
set noexrc
" Don't allow certain things in project RCs that are not owned by me, in case
" I ever enable exrc again at runtime.
set secure

" Set terminal/window title from current file.
set title
