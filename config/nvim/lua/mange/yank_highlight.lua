local yank_highlight = {}

function yank_highlight.setup()
  vim.cmd([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
  ]])
end

return yank_highlight
