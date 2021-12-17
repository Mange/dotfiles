local cmd = vim.cmd
local opt = vim.o
local g = vim.g

local theme = {}

local function theme_shared()
  vim.api.nvim_exec(
    [[
      " Transparent background
      hi Normal ctermbg=None guibg=None

      " Italics on some things
      hi GruvboxRedItalic ctermfg=167 guifg=#fb4934 cterm=italic gui=italic
      hi GruvboxAquaItalic ctermfg=108 guifg=#8ec07c cterm=italic gui=italic

      hi link rustConditional GruvboxRedItalic
      hi link rustRepeat GruvboxRedItalic
      hi link rustKeyword GruvboxRedItalic

      hi link rubyClass GruvboxAquaItalic
      hi link rubyModule GruvboxAquaItalic
      hi link cssAtRule GruvboxAquaItalic
      hi link cssAtKeyword GruvboxAquaItalic

      " Improve warning look
      hi RedUndercurl cterm=undercurl gui=undercurl guisp=#fb4934
      hi YellowUndercurl cterm=undercurl gui=undercurl guisp=#fabd2f
      hi BlueUndercurl cterm=undercurl gui=undercurl guisp=#83a598
    ]],
    false
  )
end

local function theme_light()
  opt.background = "light"
  theme_shared()
end

local function theme_dark()
  opt.background = "dark"
  theme_shared()

  vim.api.nvim_exec(
    [[
      " Improve diff look
      hi clear DiffAdd
      hi DiffAdd guibg=#2c3529

      hi clear DiffChange
      hi DiffChange guibg=#353429

      hi clear DiffText
      hi DiffText guibg=#685125

      " Change FG color, which in turn changes the fillchar (see options.lua)
      " to look nicer.
      hi clear DiffDelete
      hi DiffDelete guibg=#352a29 guifg=#52413f

      " GitSigns showing deleted lines should not change FG color like
      " DiffDelete does.
      hi GitSignsDeleteLn guibg=#352a29
    ]],
    false
  )
end

function theme.reload()
  require("plenary.reload").reload_module "mange.theme"
  require("mange.theme").setup()
end

function theme.setup()
  opt.termguicolors = true

  g.gruvbox_italic = 1
  g.gruvbox_italicize_comments = 0
  g.gruvbox_contrast_dark = "medium"
  g.gruvbox_contrast_light = "hard"
  g.gruvbox_transparent_bg = 1

  g.gruvbox_improved_warnings = true

  cmd [[silent! colorscheme gruvbox]]

  if vim.env.KITTY_THEME == "light" then
    theme_light()
  else
    theme_dark()
  end
end

return theme
