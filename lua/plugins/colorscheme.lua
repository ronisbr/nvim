-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.now(
  function()
    require("nano-theme").setup({
      light_variant = "default",
      dark_variant  = "ink",
    })

    vim.cmd.colorscheme("nano-theme")

    require("auto-dark-mode").setup()
  end
)
