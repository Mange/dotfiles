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

" Heresy!
imap <C-a> <C-o>^
nmap <C-a> ^
imap <C-e> <C-o>$
nmap <C-e> $

" Window shortcuts
nmap <Tab> <C-w><C-w>
nmap <S-Tab> <C-w><C-W>

" Other shortcuts
map <F2> :NERDTreeToggle<CR>
