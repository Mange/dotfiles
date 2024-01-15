return {
  {
    "windwp/nvim-autopairs",
    dependencies = {
      -- Wants to hook into <CR> mappings set by cmp
      "hrsh7th/nvim-cmp",
    },
    opts = {
      disable_filetype = { "TelescopePrompt" },
      ignored_next_char = "%S", -- Only act if the next character is whitespace.
    },
    config = function(_, opts)
      local npairs = require "nvim-autopairs"
      npairs.setup(opts)

      -- Add endwise-like things (auto "end", "endfunction", etc.)
      npairs.add_rules(require "nvim-autopairs.rules.endwise-lua")
      npairs.add_rules(require "nvim-autopairs.rules.endwise-ruby")
    end,
  },
}
