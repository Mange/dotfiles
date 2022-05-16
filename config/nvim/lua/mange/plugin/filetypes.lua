require("filetype").setup {
  overrides = {
    extensions = {
      rasi = "css.rasi",
    },
    literal = {
      ["notes.local"] = "markdown",
      [".notes.local"] = "markdown",
    },
    complex = {
      ["Dockerfile.*"] = "dockerfile",
      [".*chart/templates/.*.yml"] = "helm",
    },
  },
}
