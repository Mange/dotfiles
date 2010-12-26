if has("gui_running")
  set guioptions=acei
  set background=dark
  colorscheme vividchalk
  set listchars=tab:→\ ,eol:¬
  set list
  if has("gui_macvim")
    set guifont=Monaco:h12
  else
    set guifont=Monaco\ 9,\ DejaVu\ Sans\ Mono\ 9
  end
end
