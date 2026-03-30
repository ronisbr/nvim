-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.now(
  function()
    vim.cmd.colorscheme("nano-theme")
    require("auto-dark-mode").setup()
  end
)
