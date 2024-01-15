local has_ufo, _ = pcall(require, "ufo")
local has_cmp, cmp = pcall(require, "cmp_nvim_lsp")
local has_navic, navic = pcall(require, "nvim-navic")

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  focus = false,
})
vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
    focus = false,
  })

local function capabilities(func)
  local caps
  if has_cmp then
    caps = cmp.default_capabilities()
  else
    caps = vim.lsp.protocol.make_client_capabilities()
  end

  if has_ufo then
    caps.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }
  end

  if func then
    func(caps)
  end

  return caps
end

local function buffer_autocmd(bufnr, group_name, event, callback)
  local group = vim.api.nvim_create_augroup(group_name, { clear = false })
  vim.api.nvim_clear_autocmds {
    group = group,
    event = event,
    buffer = bufnr,
  }
  vim.api.nvim_create_autocmd(event, {
    group = group,
    buffer = bufnr,
    callback = callback,
  })
end

local function on_attach_without_formatting(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  buffer_autocmd(bufnr, "LspDiagnosticHover", "CursorHold", function()
    require("mange.utils").show_diagnostic_float()
  end)

  -- if client.server_capabilities.signatureHelpProvider then
  --   buffer_autocmd(bufnr, "LspSignatureHelp", "CursorHoldI", function()
  --     require("mange.utils").show_signature_help()
  --   end)
  -- end

  if client.server_capabilities.documentHighlightProvider then
    vim.cmd [[
      hi LspReferenceRead guibg=#5f5840
      hi LspReferenceText guibg=#504945
      hi LspReferenceWrite guibg=#6c473e
      augroup lsp_document_highlight
      autocmd! * <buffer>
      autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]
  end

  if has_navic and client.server_capabilities.documentSymbolProvider then
    -- Work around navic being pissy about attaching multiple clients on the same buffer
    if not vim.b.navic_client_id then
      navic.attach(client, bufnr)
    end
  end

  require("mange.mappings").attach_lsp(bufnr)
end

local function on_attach(...)
  on_attach_without_formatting(...)
end

if_require("lspconfig", function(lspconfig)
  -- Lua
  -- Try to configure this to work both in Neovim and in AwesomeWM
  -- environments. This does not seem to be possible to do well, so try to
  -- configure the union of these environments.
  lspconfig.lua_ls.setup {
    cmd = { "lua-language-server" },
    capabilities = capabilities(),
    on_attach = on_attach_without_formatting,
    settings = {
      Lua = {
        -- Neovim runs LuaJIT
        runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
        diagnostics = {
          enable = true,
          -- Add AwesomeWM and NeoVim globals here…
          globals = {
            "vim",
            "describe",
            "it",
            "before_each",
            "after_each",
            "awesome",
            "theme",
            "client",
            "P",
          },
        },
        telemetry = {
          enable = false,
        },
      },
    },
    prefix = "lua",
  }

  --  Ruby / Solargraph
  lspconfig.solargraph.setup {
    capabilities = capabilities(),
    cmd = { "bundle", "exec", "solargraph", "stdio" },
    on_attach = on_attach,
    prefix = "solargraph",
  }

  --  HTML, CSS, Tailwind, etc.
  lspconfig.html.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
    filetypes = { "html", "eruby" },
  }
  lspconfig.cssls.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
  }
  lspconfig.tailwindcss.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
  }

  --  Typescript / tsserver
  --  This is set up through typescript-tools.nvim in plugins/code.lua

  lspconfig.eslint.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
  }

  lspconfig.bashls.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
  }

  lspconfig.ccls.setup {
    capabilities = capabilities(function(caps)
      caps.offsetEncoding = { "utf-16" }
    end),
    on_attach = on_attach,
  }

  lspconfig.terraformls.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
  }

  lspconfig.nil_ls.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
  }

  lspconfig.dockerls.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
  }

  lspconfig.graphql.setup {
    capabilities = capabilities(),
    on_attach = on_attach_without_formatting,
  }

  -- lspconfig.yamlls.setup {
  --   capabilities = capabilities(),
  --   on_attach = function(client, buffer)
  --     -- https://github.com/redhat-developer/yaml-language-server/issues/486
  --     client.server_capabilities.documentFormattingProvider = true
  --     on_attach(client, buffer)
  --   end,
  --   settings = {
  --     yaml = {
  --       customTags = {},
  --     },
  --     format = {
  --       enable = true,
  --       proseWrap = "always",
  --       printWidth = 100,
  --     },
  --     redhat = {
  --       telemetry = { enabled = false },
  --     },
  --   },
  -- }

  -- TODO:
  -- SQL
end)

return {
  on_attach = on_attach,
  capabilities = capabilities,
}
