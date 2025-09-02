return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ccls = {
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
        },
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
