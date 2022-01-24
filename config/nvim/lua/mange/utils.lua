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

-- Filetypes that should default to having autoformatting OFF. Enable on
-- buffers when you do want it.
local disabled_autoformat_types = {
  "markdown",
  "vimwiki",
  "eruby", -- Breaks completely in most formatters
}

-- Sloooooow autoformatters should run async instead of sync. You'll need to
-- save again afterwards if something changed, but that should happen
-- automatically in most cases due to my default of "saving all buffers".
local slow_autoformat = {
  "ruby",
}

--- @return boolean
function utils.should_autoformat_buffer()
  local override = vim.b.mange_autoformat_override

  if override == true or override == false then
    return override
  else
    return not vim.tbl_contains(disabled_autoformat_types, vim.bo.filetype)
  end
end

function utils.maybe_autoformat()
  if utils.should_autoformat_buffer() then
    if vim.tbl_contains(slow_autoformat, vim.bo.filetype) then
      vim.lsp.buf.formatting()
    else
      vim.lsp.buf.formatting_sync(nil, 1000)
    end
  end
end

--- @param enabled boolean
function utils.buf_set_autoformat(enabled)
  vim.b.mange_autoformat_override = enabled

  if enabled == true then
    print "Autoformatting enabled (override)"
  elseif enabled == false then
    print "Autoformatting disabled (override)"
  else
    print "Autoformatting automatic (no override)"
  end
end

function utils.buf_toggle_autoformat()
  utils.buf_set_autoformat(not utils.should_autoformat_buffer())
end

return utils
