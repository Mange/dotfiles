let g:taskwiki_taskrc_location = '~/.config/taskwarrior/config'

let personal_wiki = {}
let personal_wiki.path = '~/Documents/Wiki/Personal/'
let personal_wiki.template_path = '~/Documents/Wiki/templates/personal/'
let personal_wiki.html_template = '~/Documents/Wiki/html/personal/'
let personal_wiki.auto_tags = 1

let hemnet_wiki = {}
let hemnet_wiki.path = '~/Documents/Wiki/Hemnet/'
let hemnet_wiki.template_path = '~/Documents/Wiki/templates/hemnet/'
let hemnet_wiki.html_template = '~/Documents/Wiki/html/hemnet/'
let hemnet_wiki.auto_tags = 1

let g:vimwiki_list = [personal_wiki, hemnet_wiki]

" Not supported by taskwiki
" https://github.com/tbabej/taskwiki/issues/119
" let g:vimwiki_listsyms = ' ○◐●'

let g:vimwiki_folding = 'list'
