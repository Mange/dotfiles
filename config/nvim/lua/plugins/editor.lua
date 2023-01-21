return {
  {
    "kylechui/nvim-surround",
    opts = {},
    event = "InsertEnter",
  },

  -- Replace with dial.nvim? https://github.com/monaqa/dial.nvim
  -- Also replaces vim-speeddating
  {
    "AndrewRadev/switch.vim",
    init = function()
      vim.g.switch_mapping = "" -- Setup in mange.mappings
    end,
  },

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

  {
    "junegunn/vim-easy-align",
    cmd = { "EasyAlign", "LiveEasyAlign" },
    event = "InsertEnter",
  },
}
