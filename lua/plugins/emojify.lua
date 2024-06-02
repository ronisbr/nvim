-- Description -----------------------------------------------------------------------------
--
-- Configuration of emojify.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "ronisbr/emojify.nvim",
    lazy = false,

    config = function ()
      require("emojify").setup({
        inlay = true
      })
      vim.cmd("Emojify")
    end,
  }
}

-- vim:ts=2:sts=2:sw=2:et

