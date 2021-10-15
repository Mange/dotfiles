local cursorline = {
  enabled = true,
}

function cursorline.toggle()
  cursorline.enabled = not cursorline.enabled
  cursorline.apply()
end

function cursorline.apply()
  vim.wo.cursorline = cursorline.enabled
end

function cursorline.setup()
  vim.cmd([[
    augroup MangeCursorline
      autocmd!
      autocmd WinEnter,BufEnter * :lua require("mange.cursorline").apply()

      autocmd WinLeave,BufLeave * :setlocal nocursorline
    augroup END
  ]])
end

return cursorline
