" This is sooo nice
nmap <Space> :

" Shift-H and Shift-L to switch tabs
map <S-h> gT
map <S-l> gt

" CTRL-<navigation> to move windows
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

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

" Quick list shortcuts
nmap <Tab> :cn<CR>
nmap <S-Tab> :cp<CR>

" Unmap Q
" I'll use it for context-sensitive actions depending on filetype
map <expr> Q ''

" Fugitive mappings
nmap <F1> :Gstatus<CR>
nmap <F2> :Gcommit --all<CR>

" Inserts the path of the currently edited file into a command
cmap <C-p> <C-R>=expand("%:p:h") . "/" <CR>

map <silent> <leader>r :CommandTFlush<CR>

