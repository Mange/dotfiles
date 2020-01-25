function! SplitOrFocus(fname)
    let bufnum=bufnr(expand(a:fname))
    let winnum=bufwinnr(bufnum)
    if winnum != -1
        " Jump to existing split
        exe winnum . "wincmd w"
    else
        " Make new split as usual
        exe "split " . a:fname
    endif
endfunction
command! -nargs=1 SplitOrFocus :call SplitOrFocus("<args>")

" Takes command and a string like "<name>\t<full path>" and runs the command
" with "<full path"> as the argument.
function! s:dirsHelper(command, result)
  let l:path = split(a:result, "\t")[1]
  execute a:command . " " . fnameescape(l:path)
endfunction

" User gets to choose one directory in given path (default ".") and then CD to
" this directory.
function! DirsCD(...)
  let path = a:0 >= 1 ? a:1 : "."

  call fzf#run({
        \ 'source': 'find ' . shellescape(expand(path)) . ' -maxdepth 1 -mindepth 1 -type d -printf "%f\t%p\n"',
        \ 'options': '--with-nth 1',
        \ 'sink': function('s:dirsHelper', ['cd']),
        \ })
endfunction
command! -nargs=1 DirsCD :call DirsCD("<args>")
