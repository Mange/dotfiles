let g:taskwiki_taskrc_location = '~/.config/taskwarrior/config'

let g:vimwiki_key_mappings =
\ {
\   'all_maps': 0,
\   'global': 0,
\   'headers': 1,
\   'text_objs': 1,
\   'table_format': 1,
\   'table_mappings': 1,
\   'lists': 1,
\   'links': 1,
\   'html': 1,
\   'mouse': 0,
\ }

let personal_wiki = {}
let personal_wiki.path = '~/Documents/Wiki/Personal/'
let personal_wiki.template_path = '~/Documents/Wiki/templates/personal/'
let personal_wiki.html_template = '~/Documents/Wiki/html/personal/'
let personal_wiki.auto_tags = 1

let work_wiki = {}
let work_wiki.path = '~/Documents/Wiki/Work/'
let work_wiki.template_path = '~/Documents/Wiki/templates/work/'
let work_wiki.html_template = '~/Documents/Wiki/html/work/'
let work_wiki.auto_tags = 1

let g:vimwiki_list = [personal_wiki, work_wiki]

" Not supported by taskwiki
" https://github.com/tbabej/taskwiki/issues/119
" let g:vimwiki_listsyms = ' ○◐●'

let g:vimwiki_folding = 'list'
