" Shift-H and Shift-L to switch tabs
map <S-h> gT
map <S-l> gt

" Shortcuts to use system clipboard
if v:progname =~? "gvim"
  vmap <C-c> "+y
  vmap <C-x> "+x
  imap <C-v> "+p
  nmap <C-v> "+p
endif

" Shortcut for saving in all modes
noremap <C-s> :w<cr>
inoremap <C-s> <C-o>:w<CR>

" Other shortcuts
map <F2> :NERDTreeToggle<CR>

