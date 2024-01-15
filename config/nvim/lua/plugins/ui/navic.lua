local icons = require "config.icons"

return {
  -- Show semantic/scope location of cursor in current buffer
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
      vim.g.navic_silence = true
      require("mange.utils").on_lsp_attach(function(client, bufnr)
        if client.supports_method("textDocument/documentSymbol") then
          require("nvim-navic").attach(client, bufnr)
        end
      end)
    end,
    opts = {
      depth_limit = 5,
      highlight = true,
      icons = icons.kinds,
      separator = " ",
      lazy_update_context = true,
    },
  },
  {
    "hoob3rt/lualine.nvim",
    opts = function(_, opts)
      table.insert(
        opts.sections.lualine_b,
        {
          function()
            return require("nvim-navic").get_location()
          end,
          cond = function()
            return package.loaded["nvim-navic"]
              and require("nvim-navic").is_available()
          end,
        }
      )
    end,
  }
}
