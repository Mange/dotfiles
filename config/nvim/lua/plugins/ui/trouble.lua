return {
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
      use_diagnostic_signs = true,
    },
    setup = function(_, opts)
      require("trouble").setup(opts)

      vim.api.nvim_create_autocmd("QuickFixCmdPost", {
        callback = function()
          vim.cmd [[Trouble qflist open]]
        end,
      })
    end,
  },
}
