local npairs = require "nvim-autopairs"

npairs.setup {
  disable_filetype = { "TelescopePrompt" },
}

-- Add endwise-like things (auto "end", "endfunction", etc.)
npairs.add_rules(require "nvim-autopairs.rules.endwise-elixir")
npairs.add_rules(require "nvim-autopairs.rules.endwise-lua")
npairs.add_rules(require "nvim-autopairs.rules.endwise-ruby")
