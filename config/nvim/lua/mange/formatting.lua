-- We use "disable_formatting" rather than "enable_formatting" because it
-- should be enabled by default and disabling is more like an override.
return {
  globally_enabled = function()
    return vim.g.disable_autoformat ~= true
  end,

  --- @param bufnr? number
  buffer_enabled = function(bufnr)
    bufnr = bufnr or 0
    return vim.b[bufnr].disable_autoformat ~= true
  end,

  --- @param enabled boolean?
  toggle_global = function(enabled)
    if enabled == nil then
      enabled = not vim.g.disable_autoformat
    end

    vim.g.disable_autoformat = not enabled
  end,

  --- @param enabled boolean?
  --- @param bufnr number?
  toggle_buffer = function(enabled, bufnr)
    bufnr = bufnr or 0

    if enabled == nil then
      enabled = not vim.b[bufnr].disable_autoformat
    end

    vim.b[bufnr].disable_autoformat = not enabled
  end,
}
