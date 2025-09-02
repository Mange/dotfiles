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

-- Typescript / Javascript formatting shortcut
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.keymap.set(
      "n",
      "Q",
      "<cmd>EslintFixAll<cr>",
      { buffer = true, desc = "eslint-fix-all", silent = true }
    )
  end,
})
