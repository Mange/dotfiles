" Shift-H and Shift-L to switch tabs
map <S-h> gT
map <S-l> gt

" CTRL-<navigation> to move windows
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

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

" Unmap Q
" I'll use it for context-sensitive actions depending on filetype
map <expr> Q ''

" Fugitive mappings
nmap <C-G>b :Gblame<CR>
nmap <C-G>c :Gcommit<CR>
nmap <C-G>C :Gcommit --all<CR>
nmap <C-G>d :Gdiff<CR>
nmap <C-G>l :Glog<CR>
nmap <C-G>s :Gstatus<CR>

" Inserts the path of the currently edited file into a command
cmap <C-p> <C-R>=expand("%:p:h") . "/" <CR>

" Other shortcuts
map <F2> :NERDTreeToggle<CR>

" Stolen from Janus
" https://github.com/carlhuda/janus/blob/master/gvimrc
function s:UpdateNERDTree(...)
  let stay = 0

  if(exists("a:1"))
    let stay = a:1
  end

  if exists("t:NERDTreeBufName")
    let nr = bufwinnr(t:NERDTreeBufName)
    if nr != -1
      exe nr . "wincmd w"
      exe substitute(mapcheck("R"), "<CR>", "", "")
      if !stay
        wincmd p
      end
    endif
  endif

  if exists("CommandTFlush")
    CommandTFlush
  endif
endfunction

command UpdateNERDTree call s:UpdateNERDTree()
map <silent> <leader>r :CommandTFlush<CR>:UpdateNERDTree<CR>

