-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "auto",
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
  },
  {
    "ronisbr/nano-theme.nvim",
    lazy = false,
    priority = 1000,
  }
}

-- vim:ts=2:sts=2:sw=2:et
