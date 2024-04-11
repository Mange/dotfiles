return {
  -- Better `vim.notify()`
  {
    "rcarriga/nvim-notify",
    lazy = false,
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
    config = function()
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

        return require "notify"(msg, ...)
      end
    end,
  },
}
