local group = vim.api.nvim_create_augroup("my", { clear = true })

-- Highlight yanks
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Resize windows when vim was resized
vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  callback = function()
    local currentTab = vim.fn.tabpagenr()
    vim.cmd.tabdo { args = { "wincmd", "=" } }
    vim.cmd.tabnext { args = { currentTab } }
  end,
})

-- Don't edit prose like when editing code.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    -- Line numbers does not look good when editing text.
    vim.opt_local.number = false
  end,
})

-- Automatically create directory when writing files.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(event)
    -- Skip special protocols, oil, and unnamed buffers.
    if
      event.match:match "^%w%w+://"
      or vim.bo.filetype == "oil"
      or vim.api.nvim_buf_get_name(0) == ""
    then
      return
    end

    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
