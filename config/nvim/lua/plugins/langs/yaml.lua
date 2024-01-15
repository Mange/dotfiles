return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "yaml",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        yaml = { "prettier" },
      },
    },
  },
  -- TODO: Add good LSP server for YAML?
  -- The one from RedHat is too buggy to use.
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     servers = {
  --       yamlls = { ... },
  --     },
  --   },
  -- },
}
