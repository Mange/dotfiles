" Extract selected lines to a private method
function! RubyExtractPrivateMethod()
  let name = input("Method name: ")
  if name == ''
    return
  endif

  " Move contents to m buffer
  normal! gv
  exec "normal! \"mc" . name

  " Find the class
  exec "normal! ?\\v^ *class [A-Z]\<cr>"
  " Match will be at start of the line; move up to the actual class to find
  " the inner body.
  exec "normal jvir\<esc>"

  " Look for private inside class body
  let lines = getline(line("'<"), line("'>"))
  let private_line = match(lines, "\^  \*private\$")

  if private_line > -1
    " There is a private already. Insert at the end.
    normal! '>o
  else
    " Go to the last line and insert a private.
    normal! '>
    exec "normal! o\<cr>private"
  endif

  exec "normal! odef " . name . "\<cr>end"
  exec "normal! \"mP"

  " Reindent the lines
  normal var=

  " Search for method name to remove the highlights of "private"
  " This also allows us to jump the the new method if we so wish.
  exec "normal! /\\<" . name . "\\>\<cr>"
endfunction

