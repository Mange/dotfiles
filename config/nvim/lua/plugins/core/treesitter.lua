return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang =
            vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if lang then
            pcall(vim.treesitter.start, args.buf, lang)
          end
        end,
      })
    end,
  },
}
