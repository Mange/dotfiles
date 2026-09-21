return {
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "claude_code",
        },
        inline = {
          adapter = "claude_code",
        },
        cmd = {
          adapter = "claude_code",
        },
      },
    },
    adapters = {
      acp = {
        opts = {
          show_presets = false,
        },
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            env = {
              api_key = "cmd:cat $XDG_RUNTIME_DIR/secrets/claude-oauth-token",
            },
          })
        end,
      },
    },
  },
}
