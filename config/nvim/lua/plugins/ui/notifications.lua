return {
  -- Better `vim.notify()` and LSP progress indicator.
  {
    "j-hui/fidget.nvim",
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
    config = function(_, opts)
      local fidget = require "fidget"
      fidget.setup(opts)

      local banned_messages = {
        vim.regex "^No information available$",
        vim.regex "^fswatch:",
      }

      vim.notify = function(msg, ...)
        for _, banned in ipairs(banned_messages) do
          if banned:match_str(msg) then
            return
          end
        end

        return fidget.notify(msg, ...)
      end
    end,
  },
}
