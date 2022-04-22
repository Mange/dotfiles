require("filetype").setup {
  overrides = {
    extensions = {
      rasi = "css.rasi",
    },
    literal = {
      ["notes.local"] = "vimwiki",
      [".notes.local"] = "vimwiki",
    },
    complex = {
      ["Dockerfile.*"] = "dockerfile",
      [".*chart/templates/.*.yml"] = "helm",
    },
  },
}
