-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to the Julia language.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "JuliaEditorSupport/julia-vim",
    lazy = false,

    config = function()
      vim.g.latex_to_unicode_auto = true
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
