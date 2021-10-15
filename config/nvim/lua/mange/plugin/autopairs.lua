local npairs = require("nvim-autopairs")

npairs.setup({
  disable_filetype = { "TelescopePrompt" },
})

-- Add endwise-like things (auto "end", "endfunction", etc.)
npairs.add_rules(require("nvim-autopairs.rules.endwise-elixir"))
npairs.add_rules(require("nvim-autopairs.rules.endwise-lua"))
npairs.add_rules(require("nvim-autopairs.rules.endwise-ruby"))

-- Setup smart <CR> handling; i.e. that: (| = Cursor)
--
--      {|}
--  -> Press <CR>
--  ->
--      {
--        |
--      }
--
require("nvim-autopairs.completion.cmp").setup({
  map_cr = true, --  map <CR> on insert mode
  map_complete = false, -- it will auto insert `(` (map_char) after select function or method item
  auto_select = false, -- automatically select the first item
  insert = false, -- use insert confirm behavior instead of replace
  map_char = { -- modifies the function or method delimiter by filetypes
    all = "(",
    tex = "{",
  },
})
