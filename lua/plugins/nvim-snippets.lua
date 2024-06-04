-- Description -----------------------------------------------------------------------------
--
-- Configuration of the plugin nvim-snippets.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "garymjr/nvim-snippets",
    event = { "BufReadPre", "BufNewFile" },
    version = false,

    opts = { },
  }
}

-- vim:ts=2:sts=2:sw=2:et
