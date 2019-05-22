" vim: foldmethod=marker foldlevel=1

" {{{ Base mappings

" Unmap Q
" I'll use it for context-sensitive actions depending on filetype
map <expr> Q ''

" Switch using space
nmap <Space> :Switch<cr>

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

" }}}

" {{{ Command mode

" $$ expands to current buffer's path in command mode
cnoremap %% <C-R>=expand('%')<cr>
cnoremap $$ <C-R>=expand('%:h').'/'<cr>

" }}}

" {{{ Autocomplete

" Use tab for autocompletions
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"

" }}}

" {{{ Leader mappings

let g:mapleader = "\\"
set timeoutlen=500

nnoremap <silent> <leader> :<c-u>WhichKey g:mapleader<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual g:mapleader<CR>

let g:which_key_map =  {}

" Jump to alternative file
map <leader><leader> :A<CR>
let g:which_key_map[g:mapleader] = "alternative-file"
call which_key#register(g:mapleader, "g:which_key_map")

" Close all buffers
nmap <leader>q :%bd<CR>
let g:which_key_map.q = 'close-all'

" Search for word in vim *and* Ag at the same time
" <leader>A for case-insensitive, <leader>a for smart-case
nmap <leader>a *:AgFromSearch<CR>
let g:which_key_map.a = 'project-search-word'

nmap <leader>A *:Ag -i "\b<C-r><C-w>\b"<CR>
let g:which_key_map.A = 'project-isearch-word'

" {{{ Language server keys

let g:which_key_map.l = { "name": "+language-server" }

" Remap for rename current word
nmap <leader>lr <Plug>(coc-rename)
let g:which_key_map.l.r = "rename"

" Remap for format selected region
vmap <leader>l=  <Plug>(coc-format-selected)
nmap <leader>l=  <Plug>(coc-format-selected)
let g:which_key_map.l["="] = "format-selected"

vmap <leader>lx  <Plug>(coc-codeaction-selected)
nmap <leader>lx  <Plug>(coc-codeaction)
let g:which_key_map.l.x = "code-action"

" Fix autofix problem of current line
nmap <leader>lf  <Plug>(coc-fix-current)
let g:which_key_map.l.f = "fix-current"

nnoremap <silent> <leader>la  :<C-u>CocList diagnostics<cr>
let g:which_key_map.l.a = "diagnostics"
nnoremap <silent> <leader>le  :<C-u>CocList extensions<cr>
let g:which_key_map.l.e = "extensions"
nnoremap <silent> <leader>lc  :<C-u>CocList commands<cr>
let g:which_key_map.l.c = "commands"
nnoremap <silent> <leader>lo  :<C-u>CocList outline<cr>
let g:which_key_map.l.o = "outline"
nnoremap <silent> <leader>ls  :<C-u>CocList -I symbols<cr>
let g:which_key_map.l.s = "project-symbols"
nnoremap <silent> <leader>lj  :<C-u>CocNext<CR>
let g:which_key_map.l.j = "next"
nnoremap <silent> <leader>lk  :<C-u>CocPrev<CR>
let g:which_key_map.l.k = "previous"
nnoremap <silent> <leader>lp  :<C-u>CocListResume<CR>
let g:which_key_map.l.p = "resume-last-list"
" }}}

" {{{ fzf finders
nmap <leader>T :Tags<cr>
let g:which_key_map.T = 'fzf-tags'
" }}}

" {{{ Fugitive mappings
let g:which_key_map.g = { "name": "+git" }

nmap <leader>gs :Gstatus<CR>
let g:which_key_map.g.s = 'status'

nmap <leader>ga :Gw<CR>
let g:which_key_map.g.a = 'stage-file'

nmap <leader>gc :Gcommit<CR>
let g:which_key_map.g.c = 'commit'

nmap <leader>gC :Gcommit --all<CR>
let g:which_key_map.g.C = 'commit-all'

" }}}

" {{{ Helpers for diff mode ("vimdiff")
if &diff
  set cursorline
  " Start with current search ("/" register) set to search for conflicts.
  let @/ = "<<<<<"
  nmap <leader>1 :diffget LOCAL<cr>
  let g:which_key_map.1 = 'diff-take-local'
  nmap <leader>2 :diffget BASE<cr>
  let g:which_key_map.2 = 'diff-take-base'
  nmap <leader>3 :diffget REMOTE<cr>
  let g:which_key_map.3 = 'diff-take-remote'
endif
" }}}

" {{{ Vimwiki
" Most of these bindings are added automatically by the plugin. This just adds
" nicer names to them.
let g:which_key_map.w = {
  \ "name": "+wiki",
  \ "i": "diary-index",
  \ "s": "select-ui",
  \ "t": "new-tab",
  \ "w": "open",
  \ }

" }}}

" Other misc
let g:which_key_map["*"] = "which_key_ignore"

" }}}
