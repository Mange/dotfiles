" Extract selected lines to a private method
function! RubyExtractPrivateMethod()
  let signature = input("Method signature: ")
  if signature == ''
    return
  endif

  " Move contents to m buffer and replace with signature
  normal! gv
  exec "normal! \"mc" . signature

  " Find the class
  exec "normal! ?\\v^ *class [A-Z]\<cr>"
  " Find start line and end line so we know the boundaries of the class
  let class_start = line(".")
  exec "normal %\<esc>"
  let class_end = line(".")

  " Look for private inside class body
  let lines = getline(class_start, class_end)
  let private_line = match(lines, "\^  \*private\$")

  if private_line > -1
    " There is a private already. Insert at the end.
    exec "normal! " . class_end . "GO"
  else
    " Go to the last line and insert a private.
    exec "normal! " . class_end . "G"
    exec "normal! O\<cr>private"
  endif

  exec "normal! odef " . signature . "\<cr>end"
  exec "normal! \"mP"

  " Reindent the lines
  normal var=

  " Search for method name to remove the highlights of "private"
  " This also allows us to jump the the new method if we so wish.
  let name = substitute(signature, '(.*', '', '')
  exec "normal! /\\<" . name . "\\>\<cr>"
endfunction

