return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gdscript = {
          on_attach = function(client)
            -- Start Neovim server so Godot can communicate with Neovim.
            vim.notify("Root dir: " .. tostring(client.root_dir))
            local projectpath = client.root_dir or vim.fn.getcwd()
            local pipe_file = projectpath .. "/.nvim.pipe"
            if vim.uv.fs_stat(pipe_file) == nil then
              vim.fn.serverstart(pipe_file)
            end
          end,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        gdscript = { "gdscript-formatter" },
      },
      formatters = {
        ["gdscript-formatter"] = {
          args = { "--reorder-code" },
        },
      },
    },
  },
}
