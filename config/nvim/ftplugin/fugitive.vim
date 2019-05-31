setlocal bufhidden=delete

nnoremap <buffer> <silent> c :<c-u>WhichKey "c"<CR>
nnoremap <buffer> <silent> d :<c-u>WhichKey "d"<CR>
nnoremap <buffer> <silent> r :<c-u>WhichKey "r"<CR>
nnoremap <buffer> <silent> g :<c-u>WhichKey "g"<CR>

" TODO: Describe the shortcuts that exist
let g:which_key_map_fugitive_c =  {
  \ 'c': 'commit',
  \ 'a': 'amend-and-edit',
  \ 'e': 'amend',
  \ }
let g:which_key_map_fugitive_g =  {
  \ '?': 'fugitive-mappings-help',
  \ }
let g:which_key_map_fugitive_r =  {
  \ 'a': 'rebase-abort',
  \ 'e': 'rebase-edit-todo',
  \ }
let g:which_key_map_fugitive_d =  {
  \ 'd': 'diff',
  \ }
call which_key#register("d", "g:which_key_map_fugitive_d")
