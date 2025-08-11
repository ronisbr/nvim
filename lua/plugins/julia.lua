-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to the Julia language.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.now(
  function()
    MiniDeps.add({ source = "JuliaEditorSupport/julia-vim" })

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

-- vim:ts=2:sts=2:sw=2:et
