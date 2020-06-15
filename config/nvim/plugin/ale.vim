let g:ale_fix_on_save = 1
let g:ale_line_on_text_changed = 'normal'

let g:ale_sign_warning = '⚠'
let g:ale_sign_error = '✖'
let g:ale_sign_info = '🛈'

let g:ale_virtualtext_prefix = " ❯ "
" disable, or have issues with vim-package-info
let g:ale_virtualtext_cursor = 0

let g:ale_linters = {
\   'c': [
\       'clang',
\       'clangtidy',
\   ],
\}

let g:ale_fixers = {
\   'ruby': [
\       'rubocop',
\   ],
\   'c': [
\       'clangtidy',
\       'clang-format',
\   ],
\}

let g:ale_pattern_options = {
\   '.*\.rasi$': {'ale_enabled': 0},
\}

" Use `[e` and `]e` for navigate linter errors
nmap <silent> [e <Plug>(ale_previous_wrap)
nmap <silent> ]e <Plug>(ale_next_wrap)
