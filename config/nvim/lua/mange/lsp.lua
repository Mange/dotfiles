local function capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()

  if_require("cmp_nvim_lsp", function(cmp)
    return cmp.update_capabilities(caps)
  end, function()
    return caps
  end)
end

local function unique_autocmd(name, cmd)
  vim.cmd("augroup Lsp" .. name)
  vim.cmd "  autocmd! * <buffer>"
  vim.cmd(cmd)
  vim.cmd "augroup END"
end

local function on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  unique_autocmd(
    "MaybeAutoformat",
    "autocmd BufWritePre <buffer> lua require('mange.utils').maybe_autoformat()"
  )

  unique_autocmd(
    "DiagnosticHover",
    "autocmd CursorHold <buffer> lua vim.diagnostic.open_float()"
  )

  if client.resolved_capabilities.signature_help then
    unique_autocmd(
      "SignatureHelp",
      "autocmd CursorHoldI <buffer> lua vim.lsp.buf.signature_help()"
    )
  end

  if client.resolved_capabilities.document_highlight then
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

if_require("lspconfig", function(lspconfig)
  -- Lua
  -- Try to configure this to work both in Neovim and in AwesomeWM
  -- environments. This does not seem to be possible to do well, so try to
  -- configure the union of these environments.
  lspconfig.sumneko_lua.setup {
    cmd = { "lua-language-server" },
    capabilities = capabilities(),
    on_attach = on_attach,
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
    prefix = "null",
  }

  --  Ruby / Solargraph
  lspconfig.solargraph.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
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
        -- disable tsserver formatting; format using null-ls instead
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false

        ts_utils.setup {
          enable_import_on_completion = true,
          enable_formatting = true,
        }

        ts_utils.setup_client(client)
      end)

      on_attach(client, bufnr)
    end,
  }

  lspconfig.bashls.setup {
    capabilities = capabilities(),
    on_attach = on_attach,
  }

  lspconfig.ccls.setup {
    capabilities = capabilities(),
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
  rustTools.setup {}
end)

if_require("null-ls", function(null_ls)
  null_ls.setup {
    debug = false,
    diagnostics_format = "#{m} (#{s} [#{c}])",
    should_attach = function(bufnr)
      return not vim.api.nvim_buf_get_name(bufnr):match "%.env$"
    end,
    sources = {
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.shfmt.with {
        -- Use two spaces for indentation
        extra_args = { "-i", "2" },
      },
      null_ls.builtins.formatting.stylelint,

      -- Not used because I want to trim whitespace even when I'm not using LSP
      -- on a buffer or if I disable autoformatting for some other reason.
      -- null_ls.builtins.formatting.trim_whitespace,

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
