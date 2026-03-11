-- Description -----------------------------------------------------------------------------
--
-- Configuration for gitsigns.nvim.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "lewis6991/gitsigns.nvim" })

    require("gitsigns").setup({})
  end
)
