return {
  {
    "lvimuser/lsp-inlayhints.nvim",
    event = "LspAttach",
    branch = "anticonceal",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "mange.lsp"
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        ruby = { { "standardrb", "rubocop" } },
        -- Prettier
        ["markdown.mdx"] = { { "prettierd", "prettier" } },
        css = { { "prettierd", "prettier" } },
        graphql = { { "prettierd", "prettier" } },
        handlebars = { { "prettierd", "prettier" } },
        html = { { "prettierd", "prettier" } },
        javascript = { { "prettierd", "prettier" } },
        javascriptreact = { { "prettierd", "prettier" } },
        json = { { "prettierd", "prettier" } },
        jsonc = { { "prettierd", "prettier" } },
        less = { { "prettierd", "prettier" } },
        markdown = { { "prettierd", "prettier" } },
        scss = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        typescriptreact = { { "prettierd", "prettier" } },
        vue = { { "prettierd", "prettier" } },
        yaml = { { "prettierd", "prettier" } },
      },
      -- Set up format-on-save
      format_on_save = function(bufnr)
        -- Allow disabling format on save for specific buffers.
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return false
        end

        -- Ignore format on save in common directories for installed or generated files.
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if
          bufname:match "/node_modules/"
          or bufname:match "/vendor/bundle/"
          or bufname:match "schema.rb"
          or bufname:match ".min.js$"
        then
          return false
        end

        return { timeout_ms = 500, lsp_fallback = true }
      end,
      -- Customize formatters
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require('conform').formatexpr()"
    end,
  },

  -- Dim unused variables
  { "narutoxy/dim.lua", opts = {} },

  -- Replace with a lua implementation?
  {
    "AndrewRadev/splitjoin.vim",
    event = "InsertEnter",
    init = function()
      vim.g.splitjoin_ruby_curly_braces = 0
      vim.g.splitjoin_ruby_hanging_args = 0 -- I am not insane
      vim.g.splitjoin_ruby_options_as_arguments = 1

      vim.g.splitjoin_ruby_trailing_comma = 0 -- standardrb does not like
      vim.g.splitjoin_trailing_comma = 1 -- …but I do

      vim.g.splitjoin_html_attributes_bracket_on_new_line = 1

      -- Setup in mange.mappings
      vim.g.splitjoin_split_mapping = ""
      vim.g.splitjoin_join_mapping = ""
    end,
  },

  {
    "terrortylor/nvim-comment",
    config = function()
      require("nvim_comment").setup {
        hook = function()
          if_require("ts_context_commentstring.internal", function(module)
            module.update_commentstring()
          end)
        end,
      }
    end,
  },
}
