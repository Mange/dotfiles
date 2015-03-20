let g:ctrlp_extensions = ['tag', 'mixed']

let g:ctrlp_root_markers = ['Rakefile', 'Gemfile', '.rvmrc', '.ruby-version', '.git']

let g:ctrlp_cache_dir = $HOME.'/.vim/tmp/ctrlp'

let g:ctrlp_prompt_mappings = {
  \ 'ToggleRegex()':        [],
  \ 'PrtClearCache()':      ['<F5>', '<c-r>']
  \ }
let g:ctrlp_custom_ignore = {
  \ 'dir': '\.git$\|\.svn$\|public/assets$\|vendor$\|tmp$\|log$',
  \ 'file': '\.exe$\|\.so$\|\.dll$|\.min\.js',
  \ }

" Set delay to prevent extra search
let g:ctrlp_lazy_update = 80 " ms

" If ag is available use it as filename list generator instead of 'find'
if executable("ag")
  let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --ignore ''.git'' --ignore ''.DS_Store'' --ignore ''node_modules'' --ignore ''log'' --ignore ''vendor'' --ignore ''log'' --ignore ''public/assets'' --hidden -g ""'
else
  let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files']
endif

" PyMatcher for CtrlP
if has('python')
  let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
endif
