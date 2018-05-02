" Toggle certain display settings
" I don't know whom to attribute this to, but I got it from here:
" https://gist.github.com/722047 (AndrewRadev)
" I've also made some changes myself.

" Toggle settings:
command! -nargs=+ MapToggle call s:MapToggle(<f-args>)
function! s:MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
endfunction

MapToggle sl list
" Replaced by mapping in mappings.vim
" MapToggle sh hlsearch
MapToggle sw wrap
MapToggle ss spell
MapToggle sc cursorcolumn
MapToggle sn number
