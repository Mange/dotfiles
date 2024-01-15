return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "c",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ccls = {},
      },
      setup = {
        ccls = function(opts)
          opts.capabilities =
            vim.tbl_deep_extend("force", opts.capabilities or {}, {
              offsetEncoding = { "utf-16" },
            })
          require("lspconfig").ccls.setup(opts)
        end,
      },
    },
  },
}
