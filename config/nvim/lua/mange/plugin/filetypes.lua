require("filetype").setup {
  overrides = {
    extensions = {
      rasi = "css.rasi",
      tf = "terraform",
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
