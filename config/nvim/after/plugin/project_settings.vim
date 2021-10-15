function! s:validate_file_not_tracked_by_git(name)
  let output = system("git ls-files " . shellescape(a:name))
  if strlen(output) > 1
    echoerr "WARNING! The " . a:name . " file is tracked by git. This could be a hacking attempt!"
    return v:false
  else
    return v:true
  endif
endfunction

function! s:projectrc()
  " From testing, it does not appear like git will allow any file with a
  " `.git/` prefix to be added to a repo; it just never shows up and even `git
  " add --force` will not pick it up.
  " However, this is no guarantee so still check to make sure it's not part of
  " the repo before sourcing it. Maybe the behavior changes in the future, or
  " it could be added by manually editing the index file.
  if filereadable(".git/local.vim") && s:validate_file_not_tracked_by_git(".git/local.vim")
    source .git/local.vim
  endif

  if filereadable(".git/neovim.lua") && s:validate_file_not_tracked_by_git(".git/neovim.lua")
    source .git/neovim.lua
  endif
endfunction

autocmd! DirChanged * call s:projectrc()
call s:projectrc()
