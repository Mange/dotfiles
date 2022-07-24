local lspformat = require "lsp-format"

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = "single",
    focus = false,
  }
)

local function capabilities(func)
  local caps = vim.lsp.protocol.make_client_capabilities()

  if func then
    caps = func(caps)
  end

  if_require("cmp_nvim_lsp", function(cmp)
    return cmp.update_capabilities(caps)
  end, function()
    return caps
  end)
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

  if client.server_capabilities.signatureHelpProvider then
    buffer_autocmd(bufnr, "LspSignatureHelp", "CursorHoldI", function()
      require("mange.utils").show_signature_help()
    end)
  end

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

  require("mange.mappings").attach_lsp(bufnr)
end

local function on_attach(...)
  lspformat.on_attach(...)
  on_attach_without_formatting(...)
end

if_require("lspconfig", function(lspconfig)
  lspformat.setup {
    typescript = {
      exclude = { "tsserver" },
    },
    lua = {
      exclude = { "sumneko_lua" },
    },
    ruby = {
      -- Use standardrb via null-ls instead.
      exclude = { "solargraph" },
    },
  }
  lspformat.disable { args = "markdown" }
  lspformat.disable { args = "eruby" } -- completely breaks in most formatters

  -- Lua
  -- Try to configure this to work both in Neovim and in AwesomeWM
  -- environments. This does not seem to be possible to do well, so try to
  -- configure the union of these environments.
  lspconfig.sumneko_lua.setup {
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
    on_attach = on_attach_without_formatting,
    prefix = "solargraph",
    init_options = {
      -- Uses hardcoded Rubocop; I will use Standardrb through null-ls instead.
      formatting = false,
      diagnostics = false,
    },
  }

  --  HTML
  lspconfig.html.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
    filetypes = { "html", "eruby" },
  }

  --  Tailwindcss
  lspconfig.tailwindcss.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
  }

  --  Typescript / tsserver
  lspconfig.tsserver.setup {
    capabilities = capabilities(),
    on_attach = function(client, bufnr)
      if_require("nvim-lsp-ts-utils", function(ts_utils)
        ts_utils.setup {
          enable_import_on_completion = true,
          enable_formatting = false,
        }
        ts_utils.setup_client(client)
      end)

      on_attach_without_formatting(client, bufnr)
    end,
  }

  lspconfig.bashls.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
  }

  lspconfig.ccls.setup {
    capabilities = capabilities(function(caps)
      caps.offsetEncoding = { "utf-16" }
      return caps
    end),
    on_attach = on_attach,
  }

  lspconfig.terraformls.setup {
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

  lspconfig.yamlls.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
    settings = {
      redhat = {
        telemetry = { enabled = false },
      },
    },
  }

  -- TODO:
  -- CSS
  -- SQL
end)

if_require("rust-tools", function(rustTools)
  rustTools.setup {
    server = { on_attach = on_attach },
  }
end)

if_require("null-ls", function(null_ls)
  null_ls.setup {
    debug = false,
    diagnostics_format = "#{m} (#{s} [#{c}])",
    should_attach = function(bufnr)
      return not vim.api.nvim_buf_get_name(bufnr):match "%.env$"
    end,
    on_attach = on_attach,
    sources = {
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.shfmt.with {
        -- Use two spaces for indentation
        extra_args = { "-i", "2" },
      },
      null_ls.builtins.formatting.stylelint,

      null_ls.builtins.formatting.stylua,

      null_ls.builtins.formatting.standardrb,
      -- null_ls.builtins.formatting.rubocop,
      null_ls.builtins.diagnostics.standardrb,
      -- null_ls.builtins.diagnostics.rubocop,

      -- null_ls.builtins.diagnostics.markdownlint,
      null_ls.builtins.diagnostics.shellcheck,
      -- null_ls.builtins.diagnostics.write_good,
    },
  }
end)
