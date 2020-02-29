" vim: foldmethod=marker foldlevel=1

" Autocomplete and snippets is configured in coc.vim

" {{{ Base mappings

" Unmap Q
" I'll use it for context-sensitive actions depending on filetype
map <expr> Q ''

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
noremap <C-c><C-c> :wq<CR>
inoremap <C-c><C-c> <Esc>:wq<CR>

" Quick list shortcuts
nmap <Tab> :cn<CR>
nmap <S-Tab> :cp<CR>


" }}}

" {{{ Command mode

" $$ expands to current buffer's path in command mode
cnoremap %% <C-R>=expand('%')<cr>
cnoremap $$ <C-R>=expand('%:h').'/'<cr>

" }}}

" {{{ Leader mappings

let g:mapleader = "\<Space>"
let g:maplocalleader = "\\"
set timeoutlen=400 " Affects all key timeouts, not just leaders sadly.

nnoremap <silent> <leader> :<c-u>WhichKey g:mapleader<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual g:mapleader<CR>

nnoremap <silent> <localleader> :<c-u>WhichKey g:maplocalleader<CR>
vnoremap <silent> <localleader> :<c-u>WhichKeyVisual g:maplocalleader<CR>

let g:which_key_use_floating_win = 1
let g:which_key_map =  {}

" Leader categories:
let g:which_key_map.b = { 'name' : '+buffer' }
let g:which_key_map.c = { 'name' : '+code' }
let g:which_key_map.f = { 'name' : '+file/fold' }
let g:which_key_map.g = { 'name' : '+git' }
let g:which_key_map.h = { 'name' : '+help' }
let g:which_key_map.n = { 'name' : '+notes' }
let g:which_key_map.p = { 'name' : '+project' }
let g:which_key_map.s = { 'name' : '+search' }
let g:which_key_map.t = { 'name' : '+toggle' }
let g:which_key_map.w = { 'name' : '+window' }

" {{{ Leader root
nmap <leader><space> :Switch<cr>
let g:which_key_map[' '] = 'switch'
" }}}

" {{{ Leader +buffer
" TODO: only, save all, bookmarks?

nmap <leader>bb :Buffers<cr>
let g:which_key_map.b.b = 'fzf-buffers'

map <leader>ba :silent A<CR>
let g:which_key_map.b.a = 'goto-alternative'

map <leader>bA :silent AV<CR>
let g:which_key_map.b.A = 'split-alternative'

map <leader>br :silent R<CR>
let g:which_key_map.b.r = 'goto-related'

map <leader>bR :silent RS<CR>
let g:which_key_map.b.R = 'split-related'

map <leader>bd :bd<CR>
let g:which_key_map.b.d = 'delete-buffer'

map <leader>bD :%bd<CR>
let g:which_key_map.b.D = 'delete-all'

map <leader>bk :bd<CR>
let g:which_key_map.b.k = 'delete-buffer'

map <leader>bK :%bd<CR>
let g:which_key_map.b.K = 'delete-all'

nmap <leader>bf :Filetypes<cr>
let g:which_key_map.b.f = 'set-filetype'

nmap <leader>bl :b #<cr>
let g:which_key_map.b.l = 'goto-last'
" }}}

" {{{ Leader +code
" TODO: linter stuff, autofix stuff (no searching)

nmap <leader>ca <Plug>(coc-codelens-action)
let g:which_key_map.c.a = 'codelens-action'

vmap <leader>cA  <Plug>(coc-codeaction-selected)
nmap <leader>cA  <Plug>(coc-codeaction)
let g:which_key_map.c.A = 'code-action'

nmap <leader>cr <Plug>(coc-rename)
let g:which_key_map.c.r = 'rename'

vmap <leader>c= <Plug>(coc-format-selected)
nmap <leader>c= <Plug>(coc-format-selected)
let g:which_key_map.c['='] = 'lsp-format-selected'

nmap <leader>cf  <Plug>(coc-fix-current)
let g:which_key_map.c.f = 'fix-current'

nnoremap <silent> <leader>cd  :<C-u>CocList diagnostics<cr>
let g:which_key_map.c.d = 'diagnostics'
nnoremap <silent> <leader>ce  :<C-u>CocList extensions<cr>
let g:which_key_map.c.e = 'extensions'
nnoremap <silent> <leader>c:  :<C-u>CocList commands<cr>
let g:which_key_map.c[':'] = 'commands'
nnoremap <silent> <leader>co  :<C-u>CocList outline<cr>
let g:which_key_map.c.o = 'outline'
nnoremap <silent> <leader>cs  :<C-u>CocList -I symbols<cr>
let g:which_key_map.c.s = 'project-symbols'
nnoremap <silent> <leader>cj  :<C-u>CocNext<CR>
let g:which_key_map.c.j = 'next'
nnoremap <silent> <leader>ck  :<C-u>CocPrev<CR>
let g:which_key_map.c.k = 'previous'
nnoremap <silent> <leader>cp  :<C-u>CocListResume<CR>
let g:which_key_map.c.p = 'resume-last-list'
" }}}

" {{{ Leader +file/fold
" TODO: Copy, move, rename, browse directory, copy filename, save as, fzf directory, sudo save

nmap <leader>fs :write<CR>
let g:which_key_map.f.s = 'save'

nmap <leader>fa :wall<CR>
let g:which_key_map.f.a = 'save-all'

nmap <leader>fi :fold<CR>
let g:which_key_map.f.i = 'insert-fold'

nmap <leader>f> :set foldlevel+=1 \| :set foldlevel?<CR>
let g:which_key_map.f['>'] = 'increase-foldlevel'

nmap <leader>f< :set foldlevel-=1 \| :set foldlevel?<CR>
let g:which_key_map.f['<'] = 'decrease-foldlevel'

nmap <leader>f0 :set foldlevel=0<CR>
let g:which_key_map.f['0'] = 'foldlevel-0'

nmap <leader>f1 :set foldlevel=1<CR>
let g:which_key_map.f['1'] = 'foldlevel-1'

nmap <leader>f2 :set foldlevel=2<CR>
let g:which_key_map.f['2'] = 'foldlevel-2'

nmap <leader>f3 :set foldlevel=3<CR>
let g:which_key_map.f['3'] = 'foldlevel-3'

nmap <leader>f4 :set foldlevel=4<CR>
let g:which_key_map.f['4'] = 'foldlevel-4'

nmap <leader>f5 :set foldlevel=5<CR>
let g:which_key_map.f['5'] = 'foldlevel-5'

nmap <leader>f6 :set foldlevel=6<CR>
let g:which_key_map.f['6'] = 'foldlevel-6'

nmap <leader>f7 :set foldlevel=7<CR>
let g:which_key_map.f['7'] = 'foldlevel-7'

nmap <leader>f8 :set foldlevel=8<CR>
let g:which_key_map.f['8'] = 'foldlevel-8'

nmap <leader>f9 :set foldlevel=9<CR>
let g:which_key_map.f['9'] = 'foldlevel-9'

" }}}

" {{{ Leader +git
" TODO: open browser, find, more..?
nmap <leader>gg :Gstatus<CR>
let g:which_key_map.g.g = 'status'

nmap <leader>ga :Gw<CR>
let g:which_key_map.g.a = 'stage-file'

nmap <leader>gs <Plug>(GitGutterStageHunk)
let g:which_key_map.g.s = 'stage-hunk'

nmap <leader>gu <Plug>(GitGutterUndoHunk)
let g:which_key_map.g.u = 'unstage-hunk'

nmap <leader>gp <Plug>(GitGutterPreviewHunk)
let g:which_key_map.g.p = 'preview-hunk'

nmap <leader>g/ :Commits<CR>
let g:which_key_map.g['/'] = 'fzf-commits'

let g:which_key_map.g.c = {
      \ 'name' : '+create',
      \ 'c' : ['Gcommit', 'commit'],
      \ 'C' : ['Gcommit --all --verbose', 'commit-all'],
      \ 'a' : ['Gcommit --amend --verbose', 'amend'],
      \ }
" }}}

" {{{ Leader +help
" TODO: normal help, filetype help?, fugitive help?, doctor?
nmap <leader>hh :Helptags<cr>
let g:which_key_map.h.h = 'fzf-helptags'
" }}}

" {{{ Leader +notes
" TODO: Show calendar? Show tasks or something?

nmap <leader>nn :SplitOrFocus notes.local<cr>
let g:which_key_map.n.n = 'local-notes'

nmap <leader>nw :VimwikiTabIndex<cr>
let g:which_key_map.n.w = 'wiki-tab'

nmap <leader>n/ :FZF ~/Documents/Wiki<cr>
let g:which_key_map.n['/'] = 'find-entry'

nmap <leader>nW :2VimwikiTabIndex<cr>
let g:which_key_map.n.W = 'work-wiki-tab'
" }}}

" {{{ Leader +project
" TODO: Open file in other project, browse directory

nmap <leader>pp :DirsCD ~/Projects<CR>
let g:which_key_map.p.p = 'select-project'

nmap <leader>pf :FZF<CR>
let g:which_key_map.p.f = 'find-file'

" }}}

" {{{ Leader +search
" TODO: Search project, symbols, tags, etc.

" Search for word in vim *and* Ag at the same time
nmap <leader>sw *:AgFromSearch<CR>
let g:which_key_map.s.w = 'project-search-word'

nmap <leader>st :Tags<cr>
let g:which_key_map.s.t = 'fzf-tags'

" Go back to the previous quickfix list (e.g. older search results)
nmap <leader>sk :colder<cr>
let g:which_key_map.s.k = 'list-older'

" Go to the next quickfix list (e.g. newer search results)
nmap <leader>sj :cnewer<cr>
let g:which_key_map.s.j = 'list-newer'
" }}}

" {{{ Leader +toggle
" TODO: big font?, light mode?, gouyo/zen, quicklist, locationlist, git
" gutter, read-only, etc.

nmap <leader>tv :Vista!!<CR>
let g:which_key_map.t.v = 'vista-pane'

nmap <leader>t* <Plug>SearchHighlightingAutoSearch
let g:which_key_map.t['*'] = 'auto-search'

nmap <leader>tl :set list! \| set list?<cr>
let g:which_key_map.t.l = 'listchars'

nmap <leader>tn :set number! \| set number?<cr>
let g:which_key_map.t.n = 'number'

nmap <leader>tw :set wrap! \| set wrap?<cr>
let g:which_key_map.t.w = 'wrap'

nmap <leader>ts :set spell! \| set spell?<cr>
let g:which_key_map.t.s = 'spell'

nmap <leader>tc :set cursorline! \| set cursorline?<cr>
let g:which_key_map.t.c = 'cursorline'

nmap <leader>tC :set cursorcolumn! \| set cursorcolumn?<cr>
let g:which_key_map.t.C = 'cursorcolumn'

" (thanks to SearchHighlighting plugin)
nmap <leader>th <Plug>SearchHighlightingToggleHlsearch
let g:which_key_map.t.h = 'hlsearch'

nmap <leader>tq :ClistToggle<cr>
let g:which_key_map.t.q = 'quickfix'
" }}}

" {{{ Leader +window
" TODO: Open new window, close current window, resize window, only window, fzf
" window
" }}}

" {{{ Helpers for diff mode ("vimdiff")
if &diff
  set cursorline
  " Start with current search ("/" register) set to search for conflicts.
  let @/ = '<<<<<'
  nmap <leader>1 :diffget LOCAL<cr>
  let g:which_key_map.1 = 'diff-take-local'
  nmap <leader>2 :diffget BASE<cr>
  let g:which_key_map.2 = 'diff-take-base'
  nmap <leader>3 :diffget REMOTE<cr>
  let g:which_key_map.3 = 'diff-take-remote'
endif
" }}}

call which_key#register(g:mapleader, 'g:which_key_map')
" }}}
