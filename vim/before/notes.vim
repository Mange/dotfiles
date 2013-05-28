if isdirectory($HOME . '/Dropbox/Notes')
  let g:notes_directories = ['~/Dropbox/Notes']
elseif isdirectory($HOME . '/Documents/Notes')
  let g:notes_directories = ['~/Documents/Notes']
endif
