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

command! Format execute "lua vim.lsp.buf.formatting()"
