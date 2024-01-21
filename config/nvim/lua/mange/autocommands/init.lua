-- Resize windows when vim was resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    local currentTab = vim.fn.tabpagenr()
    vim.cmd.tabdo { args = { "wincmd", "=" } }
    vim.cmd.tabnext { args = { currentTab } }
  end,
})

-- Don't edit prose like when editing code.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "markdown" },
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

-- Show diagnostics in a popup when holding cursor over one.
vim.api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  callback = function()
    require("mange.utils").show_diagnostic_float()
  end,
})
