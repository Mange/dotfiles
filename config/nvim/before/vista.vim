let g:vista_icon_indent = ["╰─契", "├─契"]
let g:vista#renderer#enable_icon = 1

if exists("*nvim_open_win")
  let g:vista_echo_cursor_strategy = "floating_win"
else
  let g:vista_echo_cursor_strategy = "echo"
endif

let g:vista_executive_for = {
      \ 'rust': 'coc',
      \ 'ruby': 'coc',
      \ 'html': 'coc',
      \ 'javascript': 'coc',
      \ 'typescript': 'coc',
      \ 'markdown': 'toc',
      \ }
