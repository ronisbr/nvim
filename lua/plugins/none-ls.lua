-- Description -----------------------------------------------------------------------------
--
-- Configuration for none-ls.nvim.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.later(
  function()
    require("null-ls").setup({
      sources = {
        require("aiwaku.lsp-code-actions")
      }
    })
  end
)
