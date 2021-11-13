local npairs = require("nvim-autopairs")
local cmp = require("cmp")

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
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
