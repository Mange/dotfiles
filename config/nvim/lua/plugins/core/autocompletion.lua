local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api
        .nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match "%s"
      == nil
end

return {
  {
    "L3MON4D3/LuaSnip",
    version = "1.*", -- follow latest release.
    build = "make install_jsregexp",
    config = function()
      local luasnip = require "luasnip"
      luasnip.config.setup { enable_autosnippets = true }
      require("luasnip.loaders.from_lua").lazy_load { paths = "./snippets" }
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "ray-x/cmp-treesitter",
    },
    config = function()
      local cmp = require "cmp"
      local luasnip = require "luasnip"
      local icons = require("config.icons").kinds

      cmp.setup {
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, item, ...)
            -- Adds color highlight if "Kind" label matches colors.
            local color_item = require("nvim-highlight-colors").format(
              entry,
              { kind = item.kind }
            )

            -- Attach icon to the "Kind" label.
            if icons[item.kind] then
              item.kind = icons[item.kind]
            else
              item.kind = icons._Unknown
            end

            -- Apply color highlights, if available.
            if color_item.abbr_hl_group then
              item.kind_hl_group = color_item.abbr_hl_group
              -- Overwrite icon with the color indicator.
              item.kind = color_item.abbr
            end

            return item
          end,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          -- Start completion with C-Space, and cancel with C-e.
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),

          -- Accept with <CR>, if an entry is selected.
          ["<CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false, -- Only confirm selection if already selected.
          },

          -- Accept copilot with C-a even when completion menu is open.
          ["<C-a>"] = function(fallback)
            local copilot_keys = vim.fn["copilot#Accept"]()
            if copilot_keys ~= "" then
              vim.api.nvim_feedkeys(copilot_keys, "i", true)
            else
              fallback()
            end
          end,

          -- Tab is a lot smarter. It will do either of the following:
          -- 1. Indent lines
          -- 2. Start completion
          -- 3. Go to the next item in completion menu
          -- 4. Advance snippet
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),

          -- Shift-tab works in reverse.
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),

          -- Scroll snippet choices, or completions with C-n, C-p
          ["<C-n>"] = function(fallback)
            if luasnip.choice_active() then
              luasnip.change_choice(1)
            elseif cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end,
          ["<C-p>"] = function(fallback)
            if luasnip.choice_active() then
              luasnip.change_choice(-1)
            elseif cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,

          -- Scroll docs with C-d and C-f.
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Don't add C-y binding. Default mapping is to select the first item and
          -- close menu afterwards.
          ["<C-y>"] = cmp.config.disable,
        },
        completion = {
          keyword_length = 4,
        },
        sources = {
          { name = "path", group_index = 1 },
          { name = "nvim_lsp", group_index = 1 },

          { name = "nvim_lua", group_index = 2 },
          { name = "crates", group_index = 2 },

          { name = "luasnip", group_index = 1 },
          { name = "treesitter", group_index = 3, keyword_length = 5 },
        },
      }
    end,
  },
}
