let g:ale_fix_on_save = 1
let g:ale_line_on_text_changed = 'normal'

let g:ale_sign_warning = '⚠️'
let g:ale_sign_error = '❌'
let g:ale_sign_info = 'ℹ️'

let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = " ❯ "

" Use `[e` and `]e` for navigate linter errors
nmap <silent> [e <Plug>(ale_previous_wrap)
nmap <silent> ]e <Plug>(ale_next_wrap)
