autocmd! BufWritePost *.{rb,js,jsx,md,txt,json} Neomake
autocmd! BufEnter *.{rb,js,jsx,md,txt,json} Neomake

autocmd! BufWritePost *.rs NeomakeProject cargo
