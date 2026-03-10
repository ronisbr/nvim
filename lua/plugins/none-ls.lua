-- Description -----------------------------------------------------------------------------
--
-- Configuration for none-ls.nvim.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "nvimtools/none-ls.nvim" })

    require("null-ls").setup({
      sources = {
        require("aiwaku.lsp-code-actions")
      }
    })
  end
)
