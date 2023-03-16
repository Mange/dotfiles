local function config()
  local npairs = require "nvim-autopairs"

  npairs.setup {
    disable_filetype = { "TelescopePrompt" },
    ignored_next_char = "%S", -- Only act if the next character is whitespace.
  }

  -- Add endwise-like things (auto "end", "endfunction", etc.)
  npairs.add_rules(require "nvim-autopairs.rules.endwise-elixir")
  npairs.add_rules(require "nvim-autopairs.rules.endwise-lua")
  npairs.add_rules(require "nvim-autopairs.rules.endwise-ruby")
end

return {
  {
    "windwp/nvim-autopairs",
    dependencies = {
      -- Wants to hook into <CR> mappings set by cmp
      "hrsh7th/nvim-cmp",
    },
    config = config,
  },
}
