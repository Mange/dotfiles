local has_navic, navic = pcall(require, "nvim-navic")

if has_navic then
  navic.setup {
    highlight = true,
  }
  vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
else
  vim.o.winbar = ""
end
