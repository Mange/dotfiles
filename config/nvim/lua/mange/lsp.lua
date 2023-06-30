local lspformat = require "lsp-format"
local inlayhints = require "lsp-inlayhints"

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

  inlayhints.on_attach(client, bufnr)

  if has_navic and client.server_capabilities.documentSymbolProvider then
    -- Work around navic being pissy about attaching multiple clients on the same buffer
    if not vim.b.navic_client_id then
      navic.attach(client, bufnr)
    end
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
      exclude = { "lua_ls" },
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
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
    on_attach = function(client, bufnr)
      on_attach_without_formatting(client, bufnr)
    end,
  }

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
    on_attach = function(client, buffer)
      -- https://github.com/redhat-developer/yaml-language-server/issues/486
      client.server_capabilities.documentFormattingProvider = true
      on_attach(client, buffer)
    end,
    settings = {
      format = {
        enable = true,
        proseWrap = "always",
        printWidth = 100,
      },
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
    tools = {
      inlay_hints = { auto = false },
    },
    server = {
      on_attach = on_attach,
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            allFeatures = true,
            overrideCommand = {
              "cargo",
              "clippy",
              "--workspace",
              "--message-format=json",
              "--all-targets",
              "--all-features",
            },
          },
        },
      },
    },
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
      --
      -- Formatting --
      --
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.shfmt.with {
        -- Use two spaces for indentation
        extra_args = { "-i", "2" },
      },
      null_ls.builtins.formatting.stylelint,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.standardrb,

      --
      -- Diagnostics --
      --
      null_ls.builtins.diagnostics.shellcheck,
      null_ls.builtins.diagnostics.ansiblelint,
      -- null_ls.builtins.diagnostics.checkmake,
      -- null_ls.builtins.diagnostics.erb_lint,
      -- null_ls.builtins.diagnostics.eslint,

      --
      -- Code actions --
      --
      -- null_ls.builtins.code_actions.eslint,
      null_ls.builtins.code_actions.gitrebase,
      -- null_ls.builtins.code_actions.refactoring,
      null_ls.builtins.code_actions.shellcheck,
    },
  }
end)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    -- Don't use LSP (mostly null-ls) to format lines with `gqq`. Most
    -- formatters and LSP servers either don't support it, care about long
    -- lines, or touch comments at all. I mainly use this to opt-in to wrap
    -- longer lines, mostly in comments and prose, which will never work well
    -- here. Formatting code in a standardized fasion is something I do on save
    -- anyway.
    vim.bo[args.buf].formatexpr = nil
  end,
})
