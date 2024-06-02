-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "ronisbr/nano-theme.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "light"
      vim.cmd.colorscheme("nano-theme")
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
