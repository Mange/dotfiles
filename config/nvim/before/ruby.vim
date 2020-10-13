let g:ruby_indent_assignment_style = "variable"

" Courtesy of vim-ruby-herefoc-syntax
let g:ruby_heredoc_syntax_filetypes = {
      \ "markdown" : {
      \   "start" : "MARKDOWN",
      \},
  \}

" Original defaults. Remove "coffee"
" let g:ruby_heredoc_syntax_defaults = {
"       \ "javascript" : {
"       \   "start" : "JS",
"       \},
"       \ "coffee" : {
"       \   "start" : "COFFEE",
"       \},
"       \ "sql" : {
"       \   "start" : "SQL",
"       \},
"       \ "html" : {
"       \   "start" : "HTML",
"       \},
"   \}
let g:ruby_heredoc_syntax_defaults = {
      \ "javascript" : {
      \   "start" : "JS",
      \},
      \ "sql" : {
      \   "start" : "SQL",
      \},
      \ "html" : {
      \   "start" : "HTML",
      \},
  \}
