--
-- Helpers for diff mode ("vimdiff")
--

-- Will only apply if started as "vimdiff", e.g. using "git mergetool".
if not vim.o.diff then
  return
end

local utils = require "mange.utils"
local wk = require "which-key"

-- Start with current search to search for conflicts.
utils.set_search "<<<<<"

-- Commands like diffget does not work well with `linematch` set.
vim.opt.diffopt = [[internal,filler,closeoff]]

wk.add {
  { "<leader>1", "<cmd>diffget LOCAL<cr>", desc = "Take local" },
  { "<leader>2", "<cmd>diffget BASE<cr>", desc = "Take base" },
  { "<leader>3", "<cmd>diffget REMOTE<cr>", desc = "Take remote" },
}
