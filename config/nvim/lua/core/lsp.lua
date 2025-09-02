vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = true,
  underline = true,
  float = {
    source = "always",
    border = "rounded",
  },
  severity_sort = true,
  update_in_insert = false,
  signs = {
    text = require("config.icons").diagnostics,
  },
}

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  focus = false,
})

vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
    focus = false,
  })

-- Limit max length of javascript-tools inlay hints, which could be whole pages
-- of text in the worst cases.
-- Hack inspired by https://github.com/MariaSolOs/dotfiles/blob/88646ab9bd20d6f36dacea0cdee8b6af3ffc4c50/.config/nvim/lua/lsp.lua#L275-L292
local inlay_handler_name = vim.lsp.protocol.Methods.textDocument_inlayHint
local original_inlay_hints = vim.lsp.handlers[inlay_handler_name]
vim.lsp.handlers[inlay_handler_name] = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)

  if client and client.name == "typescript-tools" then
    local max_inlay_hint_length = 30
    result = vim
      .iter(result)
      :map(function(hint)
        local label = hint.label ---@type string
        if label:len() > max_inlay_hint_length then
          label = label:sub(1, max_inlay_hint_length - 1) .. "…"
          hint.label = label
        end
        return hint
      end)
      :totable()
  end
  original_inlay_hints(err, result, ctx, config)
end
