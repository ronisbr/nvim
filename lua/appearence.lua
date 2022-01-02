-- Appearence configuration
-- ============================================================================

local onedarkpro = require('onedarkpro')

onedarkpro.setup({
  theme = "onedark", -- Override with "onedark" or "onelight".
  colors = {},       -- Override default colors.
  hlgroups = {},     -- Override default highlight groups.

  styles = {
      strings = "NONE",    -- Style that is applied to strings.
      comments = "italic", -- Style that is applied to comments.
      keywords = "NONE",   -- Style that is applied to keywords.
      functions = "NONE",  -- Style that is applied to functions.
      variables = "NONE",  -- Style that is applied to variables.
  },

  options = {
      bold = true,                     -- Use the themes opinionated bold styles?
      italic = true,                   -- Use the themes opinionated italic styles?
      underline = true,                -- Use the themes opinionated underline styles?
      undercurl = true,                -- Use the themes opinionated undercurl styles?
      cursorline = false,              -- Use cursorline highlighting?
      transparency = false,            -- Use a transparent background?
      terminal_colors = false,         -- Use the theme's colors for Neovim's :terminal?
      window_unfocussed_color = false, -- When the window is out of focus, change the normal background?
  }
})

onedarkpro.load()
