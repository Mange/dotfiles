-- Resize windows when vim was resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd "tabdo wincmd ="
  end,
})

-- Don't edit prose like when editing code.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.number = false
  end,
})
