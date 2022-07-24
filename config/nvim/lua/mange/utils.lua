local utils = {}

-- Set the current search; i.e. the @/ register. Regexp characters are escaped.
function utils.set_search(word)
  -- Add \V (Very Nomagic) so it becomes easier to escape the search
  -- word itself.
  local escaped = vim.fn.escape(word, "/\\")
  vim.fn.setreg("/", "\\V" .. escaped)
end

-- Set the current search; i.e. the @/ register. Regexp characters are escaped
-- and word boundaries are added to the search term.
function utils.set_search_word(word)
  -- Add \V (Very Nomagic) so it becomes easier to escape the search
  -- word itself.
  local escaped = vim.fn.escape(word, "/\\")
  vim.fn.setreg("/", "\\V\\<" .. escaped .. "\\>")
end

function utils.escape_regexp(string)
  return vim.fn.escape(string, "/.*?<>{}[]()\\")
end

function utils.unless_floating_window(fun, ...)
  -- Only works for LSP and vim.diagnostics families of floating windows…
  local existing_float = vim.b["lsp_floating_preview"]
  if not existing_float or not vim.api.nvim_win_is_valid(existing_float) then
    fun(...)
  end
end

function utils.show_signature_help(options)
  local opts = options or {}
  local force = opts.force or false

  if force then
    vim.lsp.buf.signature_help()
  else
    utils.unless_floating_window(function()
      vim.lsp.buf.signature_help()
    end)
  end
end

function utils.show_diagnostic_float(options)
  local opts = vim.tbl_extend("force", {
    force = false,
    source = "always",
    scope = "cursor",
  }, options or {})

  if opts.force then
    vim.diagnostic.open_float(opts)
  else
    utils.unless_floating_window(function()
      vim.diagnostic.open_float(opts)
    end)
  end
end

return utils
