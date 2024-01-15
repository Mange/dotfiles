return {
  {
    "luukvbaal/statuscol.nvim",
    lazy = false,
    config = function()
      local builtin = require "statuscol.builtin"
      require("statuscol").setup {
        segments = {
          -- Symbol
          { text = { "%s" }, click = "v:lua.ScSa" },
          -- Fold
          -- { text = { "%C" }, click = "v:lua.ScFa" },
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          -- Line number
          {
            text = { builtin.lnumfunc, " " },
            condition = { true, builtin.not_empty },
            click = "v:lua.ScLa",
          },
        },
      }
    end,
  },
}
