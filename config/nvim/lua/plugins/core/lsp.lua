local utils = require "mange.utils"

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      --
      -- Set up servers like this:
      -- servers = {
      --   name-of-server = { options },
      --   other-server = true,
      -- }
      --
    },
    config = function(_, opts)
      --
      -- Global handlers and setup
      --

      -- TODO: Can this be made nicer?
      utils.on_lsp_attach(function(client, _)
        if client.server_capabilities.documentHighlightProvider then
          vim.cmd [[
            augroup lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
          ]]
        end
      end)

      -- Inlay hints
      if vim.lsp.inlay_hint then
        utils.on_lsp_attach(function(client, bufnr)
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end)
      end

      --
      -- Set up all the configured servers
      --
      for server, server_opts in pairs(opts.servers) do
        -- If server opts isn't empty, set up config overrides
        if type(server_opts) == "table" then
          vim.lsp.config(server, server_opts)
        end

        vim.lsp.enable(server)
      end
    end,
  },
}
