function! SplitOrFocus(fname)
    let bufnum=bufnr(expand(a:fname))
    let winnum=bufwinnr(bufnum)
    if winnum != -1
        " Jump to existing split
        exe winnum . "wincmd w"
    else
        " Make new split as usual
        call SmartSplit(a:fname)
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

" Toggle the clist window, e.g. open if not open, and close if open.
function! ClistToggle(...)
  let windows = filter(getwininfo(), 'v:val.quickfix && !v:val.loclist')
  if len(windows) == 1
      exec "cclose"
  else
      exec "botright copen"
  endif
endfunction
command! -nargs=0 ClistToggle :call ClistToggle()

let g:smartsplit_width = 80
function! SmartSplit(args) abort
  if winwidth('.') >= 2 * g:smartsplit_width
    execute "vsplit " . a:args
  else
    execute "split " . a:args
  endif
endfunction

command! -nargs=? -complete=file SmartSplit :call SmartSplit("<args>")
