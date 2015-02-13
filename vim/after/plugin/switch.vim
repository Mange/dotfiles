" Customizing switch.vim's base offering. Specific filetypes may have more
" settings in their respective ftplugin files.

" Copied from switch.vim and changed. Changes are marked.
let g:switch_definitions =
      \ [
      \   g:switch_builtins.ampersands,
      \   g:switch_builtins.capital_true_false,
      \   g:switch_builtins.true_false,
      \ ]

autocmd FileType eruby let b:switch_definitions =
      \ [
      \   g:switch_builtins.eruby_if_clause,
      \   g:switch_builtins.eruby_tag_type,
      \   g:switch_builtins.ruby_hash_style,
      \   g:switch_builtins.ruby_string,
      \ ]

autocmd FileType haml let b:switch_definitions =
      \ [
      \   g:switch_builtins.ruby_if_clause,
      \   g:switch_builtins.ruby_hash_style,
      \   g:switch_builtins.haml_tag_type,
      \ ]

autocmd FileType php let b:switch_definitions =
      \ [
      \   g:switch_builtins.php_echo,
      \ ]

" Removed:
" g:switch_builtins.ruby_tap, " Fuck no
autocmd FileType ruby let b:switch_definitions =
      \ [
      \   g:switch_builtins.ruby_hash_style,
      \   g:switch_builtins.ruby_if_clause,
      \   g:switch_builtins.rspec_should,
      \   g:switch_builtins.rspec_expect,
      \   g:switch_builtins.rspec_be_true_false,
      \   g:switch_builtins.ruby_string,
      \   g:switch_builtins.ruby_short_blocks,
      \   g:switch_builtins.ruby_array_shorthand,
      \ ]

autocmd FileType cpp let b:switch_definitions =
      \ [
      \   g:switch_builtins.cpp_pointer,
      \ ]

autocmd FileType coffee let b:switch_definitions =
      \ [
      \   g:switch_builtins.coffee_arrow,
      \   g:switch_builtins.coffee_dictionary_shorthand,
      \ ]

autocmd FileType clojure let b:switch_definitions =
      \ [
      \   g:switch_builtins.clojure_string,
      \   g:switch_builtins.clojure_if_clause,
      \ ]
autocmd FileType scala let b:switch_definitions =
      \ [
      \   g:switch_builtins.scala_string,
      \ ]
