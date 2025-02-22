local function has_ollama()
  return vim.env.OLLAMA_API_BASE_URL ~= nil
end

local default_adapter = has_ollama() and "ollama" or "copilot"

return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = {
          adapter = default_adapter,
        },
        inline = {
          adapter = default_adapter,
        },
      },
    },
  },
}
