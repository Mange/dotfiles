return {
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      null_ls = {
        enabled = true,
      },
      src = {
        cmp = {
          enabled = true,
        },
      },
    },
  },
  { "simrat39/rust-tools.nvim" },
}
