return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "lua",
        "luadoc",
        "luap",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          -- Neovim runs LuaJIT
          runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
          diagnostics = { enable = true },
          telemetry = { enable = false },
        },
      },
      prefix = "lua",
    },
  },
}
