-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

return {
  -- {
  --   "loctvl842/monokai-pro.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("monokai-pro").setup({
  --       override = function(c)
  --         local hp = require("monokai-pro.color_helper")
  --         local common_fg = hp.lighten(c.sideBar.foreground, 30)
  --         return {
  --           NonText = {
  --             fg = c.base.dimmed3
  --           },
  --
  --           SnacksPicker = {
  --             bg = c.editor.background,
  --             fg = common_fg
  --           },
  --
  --           SnacksPickerBorder = {
  --             bg = c.editor.background,
  --             fg = c.tab.unfocusedActiveBorder
  --           },
  --
  --           SnacksPickerTree = {
  --             fg = c.editorLineNumber.foreground
  --           },
  --         }
  --       end,
  --     })
  --
  --     vim.cmd.colorscheme("monokai-pro")
  --   end
  -- },
  -- {
  --   "sainnhe/gruvbox-material",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.g.gruvbox_material_background = "medium"
  --     vim.g.gruvbox_material_enable_bold = 1
  --
  --     vim.cmd.colorscheme("gruvbox-material")
  --   end
  -- }
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "auto",
        transparent_background = true,
        highlight_overrides = {
          all = function(colors)
            return {
              MiniTablineCurrent = {
                bg = colors.surface0,
                fg = colors.text,
                sp = colors.red,
                style = { "bold" }
              },

              MiniTablineModifiedCurrent = {
                bg = colors.surface0 ,
                fg = colors.red,
                style = { "bold" }
              }
            }
          end
        }
      })

      vim.cmd.colorscheme("catppuccin")
    end
  }
  -- {
  --   "ronisbr/nano-theme.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme("nano-theme")
  --
  --     if vim.fn.has("macunix") then
  --       local current_theme
  --       current_theme = vim.fn.system("defaults read -g AppleInterfaceStyle")
  --       current_theme = current_theme:gsub("\n", "")
  --       vim.o.background = (current_theme == "Dark") and "dark" or "light"
  --
  --       -- Every 10s we check for the current theme in macOS and change the background color
  --       -- accordingly.
  --       local timer = vim.uv.new_timer()
  --       timer:start(10000, 10000, vim.schedule_wrap(
  --         function()
  --           current_theme = vim.fn.system("defaults read -g AppleInterfaceStyle")
  --           current_theme = current_theme:gsub("\n", "")
  --           vim.o.background = (current_theme == "Dark") and "dark" or "light"
  --
  --           if (vim.o.background == "light") then
  --             require("snacks").config.styles.zen.backdrop.bg = "#ECEFF1"
  --           else
  --             require("snacks").config.styles.zen.backdrop.bg = "#434C5E"
  --           end
  --         end
  --       ))
  --     else
  --       vim.o.background = "light"
  --     end
  --   end
  -- }
}

-- vim:ts=2:sts=2:sw=2:et
