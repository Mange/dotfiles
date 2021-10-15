command! -buffer -range=% FixRockets exec "<line1>,<line2>s/:\\([0-9a-z_]\\+\\) => /\\1: /g"

let b:switch_custom_definitions =
      \ [
      \   {
      \     '\[\(\D[^\]]*\)\]': '.fetch(\1)',
      \     '\.fetch(\([^)]\+\))': '[\1]'
      \   },
      \ ]
