return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "rust",
        "toml",
      })
    end,
  },
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      src = {
        cmp = {
          enabled = true,
        },
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    opts = {
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            runBuildScripts = true,
          },
          checkOnSave = {
            allFeatures = true,
            command = "clippy",
            extraArgs = { "--no-deps" },
          },
          procMacro = {
            enable = true,
            ignored = {
              ["async-trait"] = { "async_trait" },
              ["napi-derive"] = { "napi" },
              ["async-recursion"] = { "async_recursion" },
            },
          },
          completion = {
            callable = {
              -- Locked into snippets forever after accepting a function call is really uncomfortable.
              -- Does not seem to work, however…?
              snippets = "none",
            },
          },
          -- Allow Treesitter embedded highlights inside strings.
          semanticHighlighting = { strings = { enable = false } },
        },
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("force", {}, opts)
    end,
  },

  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      vim.list_extend(opts.adapters, {
        require "rustaceanvim.neotest",
      })
    end,
  },
}
