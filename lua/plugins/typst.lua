-- Description -----------------------------------------------------------------------------
--
-- Configuration for typst-preview.nvim.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "chomosuke/typst-preview.nvim" })
    require("typst-preview").setup({})
  end
)
