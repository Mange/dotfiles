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

" Hashrocket!
imap <C-l> <Space>=><Space>

" Window shortcuts
nmap <Tab> <C-w><C-w>
nmap <S-Tab> <C-w><C-W>

" Friendlier indentation
vnoremap > >gv
vnoremap < <gv

" Fugitive mappings
nmap <C-G>b :Gblame<CR>
nmap <C-G>c :Gcommit<CR>
nmap <C-G>C :Gcommit --all<CR>
nmap <C-G>d :Gdiff<CR>
nmap <C-G>l :Glog<CR>
nmap <C-G>s :Gstatus<CR>

" Other shortcuts
map <F2> :NERDTreeToggle<CR>
nmap <Space> :
