-- Description -----------------------------------------------------------------------------
--
-- Configuration for typst-preview.nvim.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.on_filetype(
  "typst",
  function()
    require("typst-preview").setup()
  end
)
