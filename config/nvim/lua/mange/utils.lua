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

function utils.feed_escape()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<esc>", true, false, true),
    "n",
    true
  )
end

--- @return number, number, number, number, number
function utils.selection_range()
  local buf, start_row, start_col = table.unpack(vim.fn.getpos "v")
  local _, end_row, end_col = table.unpack(vim.fn.getpos ".")
  if start_row < end_row or (start_row == end_row and start_col <= end_col) then
    return buf, start_row - 1, start_col - 1, end_row - 1, end_col
  else
    return buf, end_row - 1, end_col - 1, start_row - 1, start_col
  end
end

-- TODO: Does not support visual line mode.
function utils.get_selection()
  local buf, s_row, s_col, e_row, e_col = utils.selection_range()
  local lines = vim.api.nvim_buf_get_text(buf, s_row, s_col, e_row, e_col, {})
  return table.concat(lines, "\n")
end

function utils.replace_selection(new_string)
  local buf, s_row, s_col, e_row, e_col = utils.selection_range()
  local lines = vim.split(new_string, "\n")
  vim.api.nvim_buf_set_text(buf, s_row, s_col, e_row, e_col, lines)
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

---@param on_attach fun(client, buffer: number): nil
---@param opts? {group?: string|number}
function utils.on_lsp_attach(on_attach, opts)
  vim.api.nvim_create_autocmd("LspAttach", {
    group = opts and opts.group or nil,
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

return utils
