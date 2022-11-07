local has_navic, navic = pcall(require, "nvim-navic")
local has_devicons, devicons = pcall(require, "nvim-web-devicons")

local M = {}

M.winbar_filetype_exclude = {
  "help",
  "startify",
  "dashboard",
  "packer",
  "neogitstatus",
  "NvimTree",
  "Trouble",
  "alpha",
  "lir",
  "Outline",
  "spectre_panel",
  "toggleterm",
}

local function is_excluded()
  if vim.tbl_contains(M.winbar_filetype_exclude, vim.bo.filetype) then
    return true
  else
    return false
  end
end

local function render_file()
  local filename = "%t"
  local file_icon = ""

  if has_devicons then
    local icon_name = "DevIcon"
    local extension = vim.fn.expand "%:e"
    if extension ~= "" then
      icon_name = icon_name .. extension
    end

    local icon = devicons.get_icon(filename, extension, { default = true })
    file_icon = " %#" .. icon_name .. "#" .. icon .. "%*"
  end

  return file_icon .. " " .. filename .. "%*"
end

local function render_navic()
  if has_navic and navic.is_available() then
    local location = navic.get_location()
    if location ~= "" then
      return "%#WinBarSeparator#  %*" .. location
    end
  end

  return ""
end

function M.render()
  if is_excluded() then
    vim.wo.winbar = nil
    return ""
  end

  local file = render_file()
  local navic_location = render_navic()

  return file .. navic_location
end

function M.setup()
  vim.opt.winbar = "%{%v:lua.require('mange.winbar').render()%}"

  -- Use a global statusbar instead of one for each
  -- window.
  vim.opt.laststatus = 3
end

return M
