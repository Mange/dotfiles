local formatting = require "mange.formatting"

--
-- Autoformatting settings
--
vim.api.nvim_create_user_command("FormatDisable", function(args)
  -- FormatDisable! will disable formatting globally
  if args.bang then
    formatting.toggle_global(false)
  else
    formatting.toggle_buffer(false)
  end
end, {
  desc = "Disable autoformat",
  bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function(args)
  -- Formatenable! will enable formatting globally
  if args.bang then
    formatting.toggle_global(true)
  else
    formatting.toggle_buffer(true)
  end
end, {
  desc = "Re-enable autoformat",
  bang = true,
})

vim.api.nvim_create_user_command("FormatToggle", function(args)
  -- FormatToggle! will toggle formatting globally
  if args.bang then
    formatting.toggle_global()
  else
    formatting.toggle_buffer()
  end
end, {
  desc = "Toggle autoformat",
  bang = true,
})

vim.api.nvim_create_user_command("Format", function(args)
  -- Format! will format even if disabled.
  if
    args.bang
    or (formatting.globally_enabled() and formatting.buffer_enabled())
  then
    require("conform").format { async = true, lsp_fallback = true }
  end
end, {
  desc = "Format",
})
