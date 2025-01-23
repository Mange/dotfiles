local icons = require "config.icons"

--
-- Configure diagnostics
--
vim.diagnostic.config {
  virtual_text = false, -- Replaced by tiny-inline-diagnostic
  signs = true,
  underline = true,
  float = {
    source = "always",
    border = "rounded",
  },
  severity_sort = true,
  update_in_insert = false,
}

for type, icon in pairs(icons.diagnostics) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
