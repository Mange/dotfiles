local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api
        .nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match "%s"
      == nil
end

local function config()
  ---@diagnostic disable-next-line: different-requires
  local cmp = require "cmp"
  local snippy = require "snippy"
  local icons = require("config.icons").kinds

  cmp.setup {
    formatting = {
      format = function(_, item)
        if icons[item.kind] then
          item.kind = icons[item.kind] .. item.kind
        end
        return item
      end,
    },
    snippet = {
      expand = function(args)
        snippy.expand_snippet(args.body)
      end,
    },
    mapping = {
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.close(),
      ["<C-y>"] = cmp.config.disable,
      ["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false, -- Only confirm selection if already selected.
      },
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif snippy.can_expand_or_advance() then
          snippy.expand_or_advance()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif snippy.can_jump(-1) then
          snippy.previous(-1)
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
    },
    completion = {
      keyword_length = 3,
    },
    sources = {
      { name = "path" },

      { name = "nvim_lsp" },
      { name = "treesitter", max_item_count = 10, keyword_length = 5 },
      { name = "snippy" },

      { name = "nvim_lua" },
      { name = "crates" },
    },
  }
end

return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "Saecki/crates.nvim",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "ray-x/cmp-treesitter",
      "dcampos/cmp-snippy",
      "simrat39/rust-tools.nvim",
    },
    config = config,
  },
}
