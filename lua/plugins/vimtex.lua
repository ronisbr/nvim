-- Description -----------------------------------------------------------------------------
--
-- Configuration of the vimtex plugin.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "lervag/vimtex",
    lazy = false,

    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_skim_sync = 1
      vim.g.vimtex_compiler_latexmk = {
        continuous = 0
      }
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
