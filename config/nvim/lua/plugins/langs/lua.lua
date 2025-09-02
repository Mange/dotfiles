return {
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
