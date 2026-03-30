-- Description -----------------------------------------------------------------------------
--
-- Configuration of the vimtex plugin.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.now(
  function()
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_skim_sync = 1
    vim.g.vimtex_compiler_latexmk = { continuous = 0 }
  end
)

