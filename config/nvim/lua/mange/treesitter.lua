require("nvim-treesitter.configs").setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      scope_incremental = "<TAB>",
      node_decremental = "<S-TAB>",
    },
  },
  indent = {
    enable = true,
  },
  -- Setup nvim-ts-context-commentstring; second setup is with nvim-comment
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
}
