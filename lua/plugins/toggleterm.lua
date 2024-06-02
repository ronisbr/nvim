-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins toogleterm.nvim.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "akinsho/toggleterm.nvim",

    keys = {
      { "<Leader>ot", ":ToggleTerm<CR>", desc = "Open Terminal", silent = true }
    },

    opts = {
      direction = "float",
      float_opts = {
        border = "curved"
      }
    }
  }
}

-- vim:ts=2:sts=2:sw=2:et
