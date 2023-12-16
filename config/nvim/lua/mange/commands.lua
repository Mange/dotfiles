--
-- Autoformatting settings
--
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting globally
    vim.g.disable_autoformat = true
  else
    vim.b.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat",
  bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat",
})

vim.api.nvim_create_user_command("FormatToggle", function(args)
  if args.bang then
    -- FormatToggle! will toggle formatting globally
    vim.g.disable_autoformat = not vim.g.disable_autoformat
  else
    vim.b.disable_autoformat = not vim.b.disable_autoformat
  end
end, {
  desc = "Toggle autoformat",
})

vim.api.nvim_create_user_command("Format", function(args)
  -- Format! will format even if disabled.
  if args.bang or not vim.g.disable_autoformat or not vim.b.disable_autoformat then
    require("conform").format({async = true, lsp_fallback = true})
  end
end, {
  desc = "Format",
})
