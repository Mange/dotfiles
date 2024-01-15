return {
  {
    "monaqa/dial.nvim",
    config = function()
      -- Replace built-in mappings
      local map = require "dial.map"
      vim.keymap.set("n", "<C-a>", map.inc_normal(), { noremap = true })
      vim.keymap.set("n", "<C-x>", map.dec_normal(), { noremap = true })
      vim.keymap.set("v", "<C-a>", map.inc_visual(), { noremap = true })
      vim.keymap.set("v", "<C-x>", map.dec_visual(), { noremap = true })
      vim.keymap.set("v", "g<C-a>", map.inc_gvisual(), { noremap = true })
      vim.keymap.set("v", "g<C-x>", map.dec_gvisual(), { noremap = true })

      -- Configure the patterns I want to use
      local augend = require "dial.augend"
      require("dial.config").augends:register_group {
        default = {
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.integer.alias.binary,
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%H:%M"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
          augend.constant.new {
            elements = { "and", "or" },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = { "&&", "||" },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = { "if", "unless" },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = {
              "monday",
              "tuesday",
              "wednesday",
              "thursday",
              "friday",
              "saturday",
              "sunday",
            },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = {
              "January",
              "February",
              "March",
              "April",
              "May",
              "June",
              "July",
              "August",
              "September",
              "October",
              "November",
              "December",
            },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = {
              "Jan",
              "Feb",
              "Mar",
              "Apr",
              "May",
              "Jun",
              "Jul",
              "Aug",
              "Sep",
              "Oct",
              "Nov",
              "Dec",
            },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = {
              "måndag",
              "tisdag",
              "onsdag",
              "torsdag",
              "fredag",
              "lördag",
              "söndag",
            },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = {
              "januari",
              "februari",
              "mars",
              "april",
              "maj",
              "juni",
              "juli",
              "augusti",
              "september",
              "oktober",
              "november",
              "december",
            },
            word = true,
            cyclic = true,
          },
        },
      }
    end,
  },
}
