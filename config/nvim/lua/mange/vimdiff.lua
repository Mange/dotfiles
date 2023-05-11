local mappings = require "mange.mappings"
local utils = require "mange.utils"

local vimdiff = {}

-- Helpers for diff mode ("vimdiff")
-- Will only apply if started as "vimdiff", e.g. using "git mergetool".
function vimdiff.setup()
  if vim.o.diff then
    -- Start with current search to search for conflicts.
    utils.set_search "<<<<<"

    -- Commands like diffget does not work well with `linematch` set.
    vim.opt.diffopt = [[internal,filler,closeoff]]

    mappings.wk_register {
      ["<leader>"] = {
        ["1"] = { "<cmd>diffget LOCAL<cr>", "Take local" },
        ["2"] = { "<cmd>diffget BASE<cr>", "Take base" },
        ["3"] = { "<cmd>diffget REMOTE<cr>", "Take remote" },
      },
    }
  end
end

return vimdiff
