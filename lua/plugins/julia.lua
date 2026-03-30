-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to the Julia language.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.now(
  function()
    vim.g.latex_to_unicode_tab = false
    vim.g.latex_to_unicode_auto = true

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "julia",
      callback = function()
        vim.cmd("setlocal completefunc=LaTeXtoUnicode#completefunc")
      end
    })
  end
)

