-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to the Julia language.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "JuliaEditorSupport/julia-vim",
    lazy = false,
    version = false,

    config = function()
      vim.g.latex_to_unicode_tab = false
      vim.g.latex_to_unicode_auto = true
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
