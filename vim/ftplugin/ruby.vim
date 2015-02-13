setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

command! -buffer -range=% FixRockets exec "<line1>,<line2>s/:\\([0-9a-z_]\\+\\) => /\\1: /g"

vmap <buffer> <leader>mm :<C-u>call RubyExtractPrivateMethod()<cr>

let b:switch_custom_definitions =
      \ [
      \   {
      \     '\[\(\D[^\]]*\)\]': '.fetch(\1)',
      \     '\.fetch(\([^)]\))': '[\1]'
      \   },
      \ ]
