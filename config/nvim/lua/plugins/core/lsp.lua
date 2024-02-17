local utils = require "mange.utils"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  focus = false,
})

vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
    focus = false,
  })

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      --
      -- Set up servers like this:
      -- servers = { name-of-server = { options } }
      --
    },
    config = function(_, opts)
      local lspconfig = require "lspconfig"
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        opts.capabilities or {}
      )

      --
      -- Global handlers and setup
      --
      utils.on_lsp_attach(function(client, bufnr)
        require("mange.mappings").attach_lsp(client, bufnr)
      end)

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
            vim.lsp.inlay_hint.enable(bufnr, true)
          end
        end)
      end

      --
      -- Set up all the configured servers
      --
      for server, server_opts in pairs(opts.servers) do
        local final_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, server_opts)
        lspconfig[server].setup(final_opts)
      end
    end,
  },
}
