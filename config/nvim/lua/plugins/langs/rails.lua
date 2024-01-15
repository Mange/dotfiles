return {
  -- Both of these are deprecated. Replace with other.nvim?
  --
  -- Mainly for navigation commands like `:A`
  { "tpope/vim-rails", event = "VeryLazy" },
  -- …and let's add support for `:A` in other project types.
  -- (Not possible to get full fidelity for Rails apps with just projectionist)
  {
    "tpope/vim-projectionist",
    init = function()
      -- First matching project rule will stick.
      vim.g.projectionist_heuristics = {
        -- Rails
        ["Gemfile&config/boot.rb&config/application.rb"] = {
          -- Nothing special right now. Rely on default tpope/vim-rails
        },
        -- Generic ruby project
        ["Gemfile&!config/boot.rb"] = {
          ["lib/*.rb"] = {
            alternate = "spec/{}_spec.rb",
            type = "source",
          },
          ["spec/*_spec.rb"] = {
            alternate = "lib/{}.rb",
            type = "spec",
            template = {
              "# frozen_string_literal: true",
              "",
              'require "spec_helper"',
              "",
              "RSpec.describe {camelcase|capitalize|colons} do",
              "end",
            },
          },
        },
      }
    end,
    event = "VeryLazy",
  },
}
