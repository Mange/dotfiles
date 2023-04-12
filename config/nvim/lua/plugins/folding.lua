-- This requires enough setup to warrant its own plugin file

local function virtual_text_handler(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = ("  %d "):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, { suffix, "FoldedInfo" })
  return newVirtText
end

local function config()
  local ufo = require "ufo"

  vim.o.foldcolumn = "1"
  vim.o.foldlevel = 99 -- Using ufo provider need a large value
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true

  -- Using ufo provider need remap `zR` and `zM`.
  vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
  vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })

  require("ufo").setup {
    close_fold_kinds = {
      "imports",
      -- 'comment',
      -- 'region'
    },
    fold_virt_text_handler = virtual_text_handler,
  }
end

return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = config,
  },

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
