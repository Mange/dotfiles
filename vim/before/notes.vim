if isdirectory($HOME . '/Dropbox/Notes')
  let g:notes_directory = '~/Dropbox/Notes'
elseif isdirectory($HOME . '/Documents/Notes')
  let g:notes_directory = '~/Documents/Notes'
endif
