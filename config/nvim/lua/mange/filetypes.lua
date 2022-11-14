vim.filetype.add {
  extension = {
    rasi = "css.rasi",
    tf = "terraform",
  },
  filename = {
    ["notes.local"] = "markdown",
    [".notes.local"] = "markdown",
  },
  pattern = {
    [".*/Dockerfile.*"] = "dockerfile",
    [".*chart/templates/.*.yml"] = "helm",
  },
}
