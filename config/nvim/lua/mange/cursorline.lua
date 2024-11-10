local cursorline = {
  enabled = true,
}

--- @param state boolean?
function cursorline.toggle(state)
  if state ~= nil then
    cursorline.enabled = state
  else
    cursorline.enabled = not cursorline.enabled
  end

  cursorline.apply()
end

function cursorline.apply()
  vim.wo.cursorline = cursorline.enabled
end

function cursorline.setup()
  vim.cmd [[
    augroup MangeCursorline
      autocmd!
      autocmd WinEnter,BufEnter * :lua require("mange.cursorline").apply()

      autocmd WinLeave,BufLeave * :setlocal nocursorline
    augroup END
  ]]
end

return cursorline
