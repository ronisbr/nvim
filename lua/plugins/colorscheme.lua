-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.now(
  function()
    require("nano-theme").setup({
      light_variant      = "gilded",
      dark_variant       = "wood",
      transparent        = true,
      transparent_floats = false,
      float_blend        = 5,
    })

    vim.cmd.colorscheme("nano-theme")

    -- require("auto-dark-mode").setup()
  end
)
