" Jump to alternative file
map <leader><leader> :A<CR>

" Switch using space
nmap <Space> :Switch<cr>

" Use tab for autocompletions
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"

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

" Save and close window
noremap <C-d> :wq<CR>
inoremap <C-d> <Esc>:wq<CR>

" Quick list shortcuts
nmap <Tab> :cn<CR>
nmap <S-Tab> :cp<CR>

" Smart toggling of hlsearch (thanks to SearchHighlighting plugin)
nmap sh <Plug>SearchHighlightingToggleHlsearch
vmap sh <Plug>SearchHighlightingToggleHlsearch

" Unmap Q
" I'll use it for context-sensitive actions depending on filetype
map <expr> Q ''

" Fugitive mappings
nmap <leader>gs :Gstatus<CR>
nmap <leader>ga :Gw<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gC :Gcommit --all<CR>

" $$ expands to current buffer's path in command mode
cnoremap %% <C-R>=expand('%')<cr>
cnoremap $$ <C-R>=expand('%:h').'/'<cr>

" Close all buffers
nmap <leader>q :%bd<CR>

" Search for word in vim *and* Ag at the same time
" <leader>A for case-insensitive, <leader>a for smart-case
nmap <leader>a *:AgFromSearch<CR>
nmap <leader>A *:Ag -i "\b<C-r><C-w>\b"<CR>

" Helpers for diff mode ("vimdiff")
if &diff
  set cursorline
  " Start with current search ("/" register) set to search for conflicts.
  let @/ = "<<<<<"
  nmap <leader>1 :diffget LOCAL<cr>
  nmap <leader>2 :diffget BASE<cr>
  nmap <leader>3 :diffget REMOTE<cr>
endif
