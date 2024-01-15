return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "ruby",
        "yaml",
      })

      -- erb files keep crashing with treesitter.
      local old_disable = opts.highlight.disable
        or function()
          return false
        end
      opts.highlight.disable = function(lang, buf)
        if string.match(vim.api.nvim_buf_get_name(buf), ".html.erb$") then
          return true
        else
          return old_disable(lang, buf)
        end
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ruby = { { "standardrb", "rubocop" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        solargraph = {
          cmd = { "bundle", "exec", "solargraph", "stdio" },
          prefix = "solargraph",
        },
      },
    },
  },
}
