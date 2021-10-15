local plugin = {}

local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match("%s")
      == nil
end

local function feedkeys(keys, mode)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(keys, true, true, true),
    mode,
    true
  )
end

function plugin.setup()
  local cmp = require("cmp")
  local luasnip = require("luasnip")

  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = {
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.close(),
      ["<CR>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = false, -- Only confirm selection if already selected.
      }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif has_words_before() and luasnip.expand_or_jumpable() then
          feedkeys("<Plug>luasnip-expand-or-jump", "")
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if vim.fn.pumvisible() == 1 then
          feedkeys("<C-p>", "n")
        elseif luasnip.jumpable(-1) then
          feedkeys("<Plug>luasnip-jump-prev", "")
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
    },
    sources = {
      -- Shows too much. Might be appropriate in some filetypes, like text files.
      -- { name = "buffer" },
      { name = "path" },
      { name = "nvim_lsp" },
      { name = "treesitter" },
      { name = "nvim_lua" },
      { name = "crates" },
      { name = "luasnip" },
    },
  })
end

return plugin
