return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      -- Set up format-on-save
      format_on_save = function(bufnr)
        -- Allow disabling format on save for specific buffers.
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return false
        end

        -- Never try to format erb files. It's funny how bad it becomes.
        if vim.bo[bufnr].filetype == "eruby" then
          return false
        end

        -- Java is the wild west, and it's never going to be nice.
        if vim.bo[bufnr].filetype == "java" then
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
    config = function(_, opts)
      local conform = require "conform"
      conform.setup(opts)
      conform.formatters.prettier = {
        options = {
          -- Handle markdown files without markdown extension
          -- (like `notes.local` and Firenvim buffers)
          ft_parsers = { markdown = "markdown" },
        },
      }
    end,
  },
}
