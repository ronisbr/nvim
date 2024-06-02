-- Description -----------------------------------------------------------------------------
--
-- Configuration of the plugin undotree.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<Leader>ou", ":UndotreeToggle<CR>", desc = "Open Undotree", silent = true }
    }
  }
}

-- vim:ts=2:sts=2:sw=2:et
