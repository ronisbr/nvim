-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.now(
  function()
    require("nano-theme").setup({
      light_variant = "gilded",
      dark_variant  = "gilded",
    })

    vim.cmd.colorscheme("nano-theme")

    require("auto-dark-mode").setup()
  end
)
