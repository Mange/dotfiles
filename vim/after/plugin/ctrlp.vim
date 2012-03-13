let g:ctrlp_jump_to_buffer = 2 " Jump to active buffer, even if in another tab
let g:ctrlp_root_markers = ['Rakefile', 'Gemfile', '.rvmrc']
let g:ctrlp_cache_dir = $HOME.'/.vim/tmp/ctrlp'
let g:ctrlp_prompt_mappings = {
  \ 'ToggleRegex()':        [],
  \ 'PrtClearCache()':      ['<F5>', '<c-r>']
  \ }
let g:ctrlp_custom_ignore = {
  \ 'dir': '\.git$\|\.svn$\|public/assets$\|vendor$\|tmp$\|log$',
  \ 'file': '\.exe$\|\.so$\|\.dll$',
  \ }
let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files']

